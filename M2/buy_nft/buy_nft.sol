// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IBuyNFT {
    function mintBuyNFT() external;

    function viewBalance() external view returns (uint256);
}

contract BuyNFT is ERC721, IBuyNFT {
    uint256 public tokenSupply = 0;
    uint256 public constant totalSupply = 10;
    uint256 public constant price = 10 * 10 ** 18; // 10 ERC20 Token
    address immutable _owner;
    IERC20 immutable _tokenAddress;

    modifier isOwner() {
        require(msg.sender == _owner, "not contract owner");
        _;
    } // continue executing rest of method body

    constructor(address tokenAddress) ERC721("Buy", "BB") {
        _owner = msg.sender;
        _tokenAddress = IERC20(tokenAddress);
    }

    function mintBuyNFT() external {
        require(tokenSupply < totalSupply, "minting done");
        _tokenAddress.transferFrom(msg.sender, address(this), price);
        _mint(msg.sender, tokenSupply);
        tokenSupply++;
    }

    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withDrawTokens() external isOwner {
        _tokenAddress.transfer(
            msg.sender,
            _tokenAddress.balanceOf(address(this))
        );
    }

    function withDraw() external isOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmbMiTawG7wGx5KNbDfkaKpPa7eNpPxhD3tt7cooVCwdXi/";
    }
}
