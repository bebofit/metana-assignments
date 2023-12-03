// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SimpleNFT is Initializable, ERC721Upgradeable {
    uint256 public tokenSupply;
    uint256 public constant totalSupply = 10;
    uint256 public constant price = 1 ether;
    address _owner;

    error NotAuthorized();

    modifier isOwner() {
        if (msg.sender != _owner) revert NotAuthorized();
        _;
    } // continue executing rest of method body

    function initialize() external initializer {
        __ERC721_init("Simple", "SIP");
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
