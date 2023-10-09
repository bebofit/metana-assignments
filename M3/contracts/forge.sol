// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DragonTwin is ERC1155 {
    error NotAuth();
    error InvalidTokenId();
    error MintInCoolDown();
    error InSufficientTokens(string error);

    event Forged(uint256 tokenId);
    event Minted(uint256 tokenId);

    uint256 public constant GOLD = 0;
    uint256 public constant SILVER = 1;
    uint256 public constant BRONZE = 2;
    uint256 public constant THORS_HAMMER = 3; // 0,1
    uint256 public constant OBLIVION_SWORD = 4; // 1,2
    uint256 public constant CAPTAIN_SHIELD = 5; // 0,2
    uint256 public constant DANTE_KEY = 6; // 0,1,2
    uint256 public lastMint;
    uint256 public coolDownMint = 5 seconds;

    address private _owner;
    string private _url =
        "ipfs://QmVjErHSRQVmZpqUhGYPLWx75wsM8SjSTW7y3bFAMvQPr2/";

    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert NotAuth();
        }
        _;
    }

    modifier isValidTokenId(uint256 tokenId) {
        if (tokenId > 6) {
            revert InvalidTokenId();
        }
        _;
    }

    constructor()
        ERC1155("ipfs://QmVjErHSRQVmZpqUhGYPLWx75wsM8SjSTW7y3bFAMvQPr2/")
    {
        _owner = msg.sender;
    }

    function uri(
        uint256 _id
    ) public view override isValidTokenId(_id) returns (string memory) {
        return string.concat(_url, Strings.toString(_id));
    }

    function mintToken(uint256 tokenId) public isValidTokenId(tokenId) {
        if (block.timestamp - lastMint < coolDownMint) {
            revert MintInCoolDown();
        }
        lastMint = block.timestamp;
        uint256 gold = balanceOf(msg.sender, GOLD);
        uint256 silver = balanceOf(msg.sender, SILVER);
        uint256 bronze = balanceOf(msg.sender, BRONZE);
        if (tokenId == GOLD || tokenId == SILVER || tokenId == BRONZE) {
            _mint(msg.sender, tokenId, 1, "");
            emit Minted(tokenId);
        } else if (tokenId == THORS_HAMMER) {
            if (gold < 1 || silver < 1) {
                revert InSufficientTokens(
                    "must at least have one gold and one sliver"
                );
            }
            _mint(msg.sender, THORS_HAMMER, 1, "");
            _burn(msg.sender, GOLD, 1);
            _burn(msg.sender, SILVER, 1);
            emit Forged(THORS_HAMMER);
        } else if (tokenId == OBLIVION_SWORD) {
            if (bronze < 1 || silver < 1) {
                revert InSufficientTokens(
                    "must at least have one bronze and one sliver"
                );
            }
            _mint(msg.sender, OBLIVION_SWORD, 1, "");
            _burn(msg.sender, BRONZE, 1);
            _burn(msg.sender, SILVER, 1);
            emit Forged(OBLIVION_SWORD);
        } else if (tokenId == CAPTAIN_SHIELD) {
            if (bronze < 1 || gold < 1) {
                revert InSufficientTokens(
                    "must at least have one bronze and one gold"
                );
            }
            _mint(msg.sender, CAPTAIN_SHIELD, 1, "");
            _burn(msg.sender, BRONZE, 1);
            _burn(msg.sender, GOLD, 1);
            emit Forged(CAPTAIN_SHIELD);
        } else {
            if (bronze < 1 || gold < 1 || silver < 1) {
                revert InSufficientTokens(
                    "must at least have one bronze and one gold and one sliver"
                );
            }
            _mint(msg.sender, DANTE_KEY, 1, "");
            _burn(msg.sender, BRONZE, 1);
            _burn(msg.sender, GOLD, 1);
            _burn(msg.sender, SILVER, 1);
            emit Forged(DANTE_KEY);
        }
    }

    // if you want to burn your token but warning it doesnt do any app functionality
    function burn(uint256 tokenId) public isValidTokenId(tokenId) {
        if (balanceOf(msg.sender, tokenId) > 0) {
            _burn(msg.sender, tokenId, 1);
        }
    }
}
