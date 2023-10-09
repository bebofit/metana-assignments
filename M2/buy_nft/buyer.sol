// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./buy_nft.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTBuyer {
    IERC20 immutable _tokenAddress;
    IBuyNFT immutable _nftAddress;

    constructor(address tokenAddress, address nftAddress) {
        _tokenAddress = IERC20(tokenAddress);
        _nftAddress = IBuyNFT(nftAddress);
    }

    function mintNFT() public {
        // note: owner should transfer tokens to this contract before calling this method
        _tokenAddress.approve(address(_nftAddress), 10 * 10 ** 18);
        _nftAddress.mintBuyNFT();
    }
}
