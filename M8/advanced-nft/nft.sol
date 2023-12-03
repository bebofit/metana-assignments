// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "https://github.com/1001-digital/erc721-extensions/blob/main/contracts/RandomlyAssigned.sol";

error AlreadyClaimed();
error InvalidProof();
error InvalidStage();
error NotOwner();
error InvalidLength();
error SaleEnded();
error NotContributor();
error InvalidMintValue();
error AlreadyMinted();
error stillEarlyToMint(uint256 blockNumber);
error WrongHash();
error NoMoreContributors();

/*
 * @title AirDropToken
 * @notice Random NFT sale
 * @dev It is implementing ERC721 standard and commit-reveal for randomness and merkleTrees for whitelisting
 * @author bebofit
 */

contract AirDropToken is ERC721, RandomlyAssigned {
    // bytes32 = [byte, byte, ..., byte] <- 32 bytes
    bytes32 public immutable merkleRoot;
    uint256 public mintedNfts;
    uint256 public constant nftTotalSupply = 1000;
    address private immutable _owner;
    BitMaps.BitMap private _whiteList;
    uint256 public contributorCount;
    mapping(address => bool) contributors;

    struct Commit {
        bytes32 commit;
        uint64 block;
        bool revealed;
    }
    mapping(address => Commit) public commits;

    enum Stages {
        PendingStart,
        WhiteList,
        Public,
        SaleEnded
    }

    Stages public stage = Stages.PendingStart;

    event Mint(uint256 tokenId);

    modifier atStage(Stages _stage) {
        if (stage != _stage) {
            revert InvalidStage();
        }
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert NotOwner();
        }
        _;
    }

    /**
     * @notice initialize contract with merkleRoot required to be done offchain
     * @dev
     * @param _merkleRoot bytes32
     **/
    constructor(
        bytes32 _merkleRoot
    ) ERC721("AirDropNFT", "ADN") RandomlyAssigned(nftTotalSupply, 0) {
        merkleRoot = _merkleRoot;
        _owner = msg.sender;
        contributorCount = 1;
    }

    /**
     * @notice add a contributor to the nft project only owner can do it
     * @dev
     * @param contributor address
     **/
    function addContributor(address contributor) external onlyOwner {
        if (stage == Stages.SaleEnded) {
            revert NoMoreContributors();
        }
        contributors[contributor] = true;
        contributorCount++;
    }

    /**
     * @notice move project to next stage only owner can do it
     * @dev
     **/
    function NextStage() external onlyOwner {
        if (stage == Stages.PendingStart) {
            stage = Stages.WhiteList;
        } else if (stage == Stages.WhiteList) {
            stage = Stages.Public;
        }
    }

    /**
     * @notice allow for whitelisted addresses to commit their hash for the token
     * @dev note that bitmap has a max of 256 addresses
     * @param proof bytes32[] calldata
     * @param index uint256
     * @param commitHash bytes32
     **/
    function claimWhiteList(
        bytes32[] calldata proof,
        uint256 index,
        bytes32 commitHash
    ) external atStage(Stages.WhiteList) {
        // check if already claimed
        if (BitMaps.get(_whiteList, index)) {
            revert AlreadyClaimed();
        }

        // verify proof
        _verifyProof(proof, index, msg.sender);

        // set airdrop as claimed
        BitMaps.setTo(_whiteList, index, true);

        // set commit to be revealed
        _setcommit(commitHash);
    }

    /**
     * @notice verify if wallet is whitelisted or not
     * @dev verify proof of the markle tree provided all have to be done off chain
     * @param proof bytes32[] calldata
     * @param index uint256
     * @param addr address
     **/
    function _verifyProof(
        bytes32[] memory proof,
        uint256 index,
        address addr
    ) private view {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(addr, index)))
        );

        if (!MerkleProof.verify(proof, merkleRoot, leaf)) {
            revert InvalidProof();
        }
    }

    /**
     * @notice allow the public to mint using their commithash
     * @dev
     * @param commitHash bytes32
     **/
    function mint(
        bytes32 commitHash
    ) external payable atStage(Stages.Public) ensureAvailability {
        if (msg.value != 1 ether) {
            revert InvalidMintValue();
        }
        _setcommit(commitHash);
    }

    function _setcommit(bytes32 commitHash) internal {
        commits[msg.sender].commit = commitHash;
        commits[msg.sender].block = uint64(block.number);
        commits[msg.sender].revealed = false;
    }

    /**
     * @notice reveal the tokenId and mint it for whitelisted or public person
     * @dev the user must have access to the commit hash and reveal hash offchain
     * @param revealHash bytes32
     **/

    function reveal(bytes32 revealHash) external {
        if (stage != Stages.WhiteList && stage != Stages.Public) {
            revert InvalidStage();
        }
        if (commits[msg.sender].revealed) {
            revert AlreadyMinted();
        }
        if (uint64(block.number) < commits[msg.sender].block + 10) {
            revert stillEarlyToMint(block.number);
        }

        if (getHash(revealHash) != commits[msg.sender].commit) {
            revert WrongHash();
        }
        commits[msg.sender].revealed = true;
        uint256 tokenId = nextToken(); // Create a new random token ID

        emit Mint(tokenId);

        _mint(msg.sender, tokenId);
    }

    /**
     * @notice get commit hash from the data
     * @dev
     * @param data bytes32
     **/

    function getHash(bytes32 data) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), data));
    }

    /**
     * @notice allow for transferring multiple nfts in one transaction

     * @param addresses address[] calldata
     * @param tokenIds uint256[] calldata
     **/
    function bulkTransfer(
        address[] calldata addresses,
        uint256[] calldata tokenIds
    ) external returns (bool) {
        if (addresses.length != tokenIds.length) {
            revert InvalidLength();
        }

        for (uint256 i; i < addresses.length; i++) {
            _transfer(msg.sender, addresses[i], tokenIds[i]);
        }
        return true;
    }

    /**
     * @notice at the last stage of sale allow for the contributers to share the ether equally
     * @dev contributor count cannt be zero since owner is a contributor
     **/

    function withDraw() external atStage(Stages.SaleEnded) {
        // can only withdraw when sales end;
        if (!contributors[msg.sender]) {
            revert NotContributor();
        }
        // your reward is coming your way
        contributors[msg.sender] = false;
        uint256 _each = address(this).balance / contributorCount;
        payable(msg.sender).transfer(_each);
    }
}
