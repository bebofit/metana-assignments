// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./token.sol";

contract StakeNFT is ERC721Holder {
    IStakeToken public rewardsToken;
    IERC721 public nft;

    uint256 public stakedTotal;
    address immutable _owner;

    uint256 constant stakingTime = 24 hours;
    uint256 constant reward = 10 * 10 ** 18;

    struct Staker {
        mapping(uint256 => uint256) stakedTokensTime;
        uint256 balance;
        uint256 rewardsReleased;
        uint256 totalTokens;
    }

    mapping(address => Staker) public stakers;
    mapping(address => uint256) public stakedTokensTime;
    mapping(uint256 => address) public tokenOwner;

    event Staked(
        address indexed owner,
        uint256 amount,
        uint256 timestamp,
        uint256 balance
    );
    event Unstaked(address indexed owner, uint256 amount);

    error NotAuth(string msg);
    error NotNFTOWNER();
    error NoNFTStaked();
    error UnknownNFT();

    modifier isOwner() {
        if (msg.sender != _owner) {
            revert NotAuth("not authorized");
        }
        _;
    }

    constructor(IERC721 _nft, IStakeToken _rewardsToken) {
        nft = _nft;
        rewardsToken = _rewardsToken;
        _owner = msg.sender;
    }

    function onERC721Received(
        address _from,
        address,
        uint256 tokenId,
        bytes memory
    ) public override returns (bytes4) {
        if (msg.sender != address(nft)) revert UnknownNFT();
        _stake(_from, tokenId);
        return 0x12345678;
    }

    function _stake(address _user, uint256 _tokenId) internal {
        if (nft.ownerOf(_tokenId) != _user) {
            revert NotNFTOWNER();
        }
        Staker storage staker = stakers[_user];
        uint256 stakableToken = staker.stakedTokensTime[_tokenId];
        stakableToken = block.timestamp;
        tokenOwner[_tokenId] = _user;
        staker.totalTokens++;
        emit Staked(_user, _tokenId, stakableToken, staker.balance);
        stakedTotal++;
    }

    function unstake(uint256 _tokenId) public {
        if (stakers[msg.sender].stakedTokensTime[_tokenId] > 0) {
            claimReward(msg.sender, _tokenId);
        }
        _unstake(msg.sender, _tokenId);
    }

    function _unstake(address _user, uint256 _tokenId) internal {
        if (tokenOwner[_tokenId] != _user) {
            revert NotNFTOWNER();
        }
        Staker storage staker = stakers[_user];
        delete staker.stakedTokensTime[_tokenId];
        delete tokenOwner[_tokenId];

        nft.safeTransferFrom(address(this), _user, _tokenId);
        staker.totalTokens--;
        emit Unstaked(_user, _tokenId);
        stakedTotal--;
    }

    function claimReward(address _user, uint256 tokenId) public {
        if (tokenOwner[tokenId] != _user) {
            revert NotNFTOWNER();
        }
        Staker storage staker = stakers[_user];
        uint256 stackedToken = staker.stakedTokensTime[tokenId];
        if (
            stackedToken + stakingTime < block.timestamp + stakingTime &&
            stackedToken > 0
        ) {
            staker.balance +=
                (reward * (block.timestamp - uint(stackedToken))) /
                stakingTime;
            staker.stakedTokensTime[tokenId] = block.timestamp;
        }
        require(stakers[msg.sender].balance > 0, "0 rewards yet");
        uint256 rewardAmount = stakers[msg.sender].balance;
        stakers[msg.sender].rewardsReleased += rewardAmount;
        stakers[msg.sender].balance = 0;
        rewardsToken.mintToken(msg.sender, rewardAmount);
    }

    function updateReward(address _user) internal {
        Staker storage staker = stakers[_user];
        for (uint256 i = 0; i < staker.totalTokens; i++) {
            uint256 stackedToken = staker.stakedTokensTime[i];
            if (
                stackedToken + stakingTime < block.timestamp + stakingTime &&
                stackedToken > 0
            ) {
                staker.balance +=
                    (reward * (block.timestamp - uint(stackedToken))) /
                    stakingTime;
                staker.stakedTokensTime[i] = block.timestamp;
            }
        }
    }

    function claimRewardAll() public {
        if (stakers[msg.sender].totalTokens == 0) {
            revert NoNFTStaked();
        }

        updateReward(msg.sender);
        require(stakers[msg.sender].balance > 0, "0 rewards yet");

        uint256 rewardAmount = stakers[msg.sender].balance;
        stakers[msg.sender].rewardsReleased += rewardAmount;
        stakers[msg.sender].balance = 0;
        rewardsToken.mintToken(msg.sender, rewardAmount);
    }
}
