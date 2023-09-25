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

    struct StakedTokenProps {
        uint256 lastTimeStaked;
        bool isStaked;
    }
    struct Staker {
        mapping(uint256 => StakedTokenProps) stakedTokens;
        uint256 balance;
        uint256 rewardsReleased;
        uint256 totalTokens;
    }

    mapping(address => Staker) public stakers;
    mapping(uint256 => address) public tokenOwner;

    event Staked(
        address owner,
        uint256 amount,
        uint256 timestamp,
        uint256 balance
    );
    event Unstaked(address owner, uint256 amount);

    event BOO(
        uint256 time,
        uint256 numberOfStacks,
        uint256 balance,
        bool isStackedAlot
    );

    modifier isOwner() {
        require(msg.sender == _owner, "only owner");
        _;
    }

    constructor(IERC721 _nft, IStakeToken _rewardsToken) {
        nft = _nft;
        rewardsToken = _rewardsToken;
        _owner = msg.sender;
    }

    function stake(uint256 tokenId) public {
        _stake(msg.sender, tokenId);
    }

    function _stake(address _user, uint256 _tokenId) internal {
        require(
            nft.ownerOf(_tokenId) == _user,
            "user must be the owner of the token"
        );
        Staker storage staker = stakers[_user];
        StakedTokenProps storage stakableToken = staker.stakedTokens[_tokenId];
        require(!stakableToken.isStaked, "token already staked");
        require(
            block.timestamp - stakableToken.lastTimeStaked > stakingTime,
            "time hasnot passed yet till you can stake this token again please wait"
        );
        stakableToken.lastTimeStaked = block.timestamp;
        stakableToken.isStaked = true;
        tokenOwner[_tokenId] = _user;
        nft.safeTransferFrom(_user, address(this), _tokenId);
        staker.totalTokens++;
        emit Staked(
            _user,
            _tokenId,
            stakableToken.lastTimeStaked,
            staker.balance
        );
        stakedTotal++;
    }

    function unstake(uint256 _tokenId) public {
        uint256 time = stakers[msg.sender]
            .stakedTokens[_tokenId]
            .lastTimeStaked;
        uint256 numberOfStacks = ((block.timestamp - time)) / stakingTime;
        if (time > 0 && numberOfStacks > 0) {
            claimReward();
        }
        _unstake(msg.sender, _tokenId);
    }

    function _unstake(address _user, uint256 _tokenId) internal {
        require(
            tokenOwner[_tokenId] == _user,
            "Nft Staking System: user must be the owner of the staked nft"
        );
        Staker storage staker = stakers[_user];
        StakedTokenProps storage stakableToken = staker.stakedTokens[_tokenId];
        require(stakableToken.isStaked, "cannot unstake token");
        stakableToken.isStaked = false;
        delete tokenOwner[_tokenId];

        nft.safeTransferFrom(address(this), _user, _tokenId);
        staker.totalTokens--;
        emit Unstaked(_user, _tokenId);
        stakedTotal--;
    }

    function updateReward(address _user) public {
        Staker storage staker = stakers[_user];
        for (uint256 i = 0; i < staker.totalTokens; i++) {
            StakedTokenProps storage stackedToken = staker.stakedTokens[i];
            if (
                stackedToken.lastTimeStaked < block.timestamp + stakingTime &&
                stackedToken.lastTimeStaked > 0
            ) {
                uint256 numberOfStacks = (
                    (block.timestamp - uint(stackedToken.lastTimeStaked))
                ) / stakingTime;

                staker.balance += reward * numberOfStacks;
                stackedToken.lastTimeStaked = block.timestamp;
            }
        }
    }

    function claimReward() public {
        updateReward(msg.sender);
        require(stakers[msg.sender].balance > 0, "0 rewards yet");

        uint256 rewardAmount = stakers[msg.sender].balance;
        stakers[msg.sender].rewardsReleased += rewardAmount;
        stakers[msg.sender].balance = 0;
        rewardsToken.mintToken(msg.sender, rewardAmount);
    }
}
