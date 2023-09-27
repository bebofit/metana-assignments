// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SimpleNFT is ERC721 {
    uint256 public tokenSupply = 0;
    uint256 public constant totalSupply = 10;
    uint256 public constant price = 1 ether;
    address immutable _owner;

    error NotAuthorized();

    modifier isOwner() {
        if (msg.sender != _owner) revert NotAuthorized();
        _;
    } // continue executing rest of method body

    constructor() ERC721("Simple", "SIP") {
        _owner = msg.sender;
    }

    function mint() external payable {
        require(tokenSupply < totalSupply, "minting done");
        require(msg.value == price, "wrong mint price");
        _mint(msg.sender, tokenSupply);
        tokenSupply++;
    }

    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withDraw() external isOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmbMiTawG7wGx5KNbDfkaKpPa7eNpPxhD3tt7cooVCwdXi/";
    }
}
