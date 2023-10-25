// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

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

contract AirDropToken is ERC721 {
    // bytes32 = [byte, byte, ..., byte] <- 32 bytes
    bytes32 public immutable merkleRoot;
    uint256 public mintedNfts;
    uint256 public constant totalSupply = 1000;
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

    constructor(bytes32 _merkleRoot) ERC721("AirDropNFT", "ADN") {
        merkleRoot = _merkleRoot;
        _owner = msg.sender;
        contributorCount = 1;
    }

    function addContributor(address contributor) external onlyOwner {
        if (stage == Stages.SaleEnded) {
            revert NoMoreContributors();
        }
        contributors[contributor] = true;
        contributorCount++;
    }

    function NextStage() external onlyOwner {
        if (stage == Stages.PendingStart) {
            stage = Stages.WhiteList;
        } else if (stage == Stages.WhiteList) {
            stage = Stages.Public;
        }
    }

    function claimWhiteList(
        bytes32[] calldata proof,
        uint256 index
    ) external atStage(Stages.WhiteList) {
        if (stage == Stages.WhiteList) {
            // check if already claimed
            if (BitMaps.get(_whiteList, index)) {
                revert AlreadyClaimed();
            }

            // verify proof
            _verifyProof(proof, index, msg.sender);

            // set airdrop as claimed
            BitMaps.setTo(_whiteList, index, true);
        }

        // mint tokens
        _mint(msg.sender, index);
    }

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

    function commit(bytes32 dataHash) external payable atStage(Stages.Public) {
        if (mintedNfts == totalSupply) {
            stage = Stages.SaleEnded;
            revert SaleEnded();
        }
        if (msg.value != 1 ether) {
            revert InvalidMintValue();
        }
        commits[msg.sender].commit = dataHash;
        commits[msg.sender].block = uint64(block.number);
        commits[msg.sender].revealed = false;
    }

    function reveal(bytes32 revealHash) external atStage(Stages.Public) {
        if (commits[msg.sender].revealed) {
            revert AlreadyMinted();
        }
        if (uint64(block.number) < commits[msg.sender].block + 10) {
            revert stillEarlyToMint(block.number);
        }

        if (getHash(revealHash) != commits[msg.sender].commit) {
            revert WrongHash();
        }

        bytes32 blockHash = blockhash(commits[msg.sender].block);
        uint256 tokenId = uint256(
            keccak256(abi.encodePacked(blockHash, revealHash))
        ) % (totalSupply - 10);
        // to bypass the 10 ids of whitelabled nfts
        tokenId = tokenId + 10;
        ++mintedNfts;
        emit Mint(tokenId);

        _mint(msg.sender, tokenId);
    }

    function getHash(bytes32 data) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), data));
    }

    function bulkTransfer(
        address[] calldata addresses,
        uint256[] calldata tokenIds
    ) external returns (bool) {
        if (addresses.length != tokenIds.length) {
            revert InvalidLength();
        }

        for (uint i; i < addresses.length; i++) {
            _transfer(msg.sender, addresses[i], tokenIds[i]);
        }
        return true;
    }

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
