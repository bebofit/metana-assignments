// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IStakeToken {
    function setMinter(address theMinter) external;

    function mintToken(address to, uint256 amount) external;
}

contract StakeToken is ERC20 {
    address private _owner;
    address minter;

    error NotAuthorized();

    constructor(uint256 initialSupply) ERC20("STAKE", "STK") {
        _owner = msg.sender;
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    modifier isOwner() {
        if (msg.sender != _owner) revert NotAuthorized();
        _;
    }

    modifier canMint() {
        if (msg.sender != _owner && msg.sender != minter) {
            revert NotAuthorized();
        }
        _;
    }

    function setMinter(address theMinter) public isOwner {
        minter = theMinter;
    }

    function mintToken(address to, uint256 amount) public canMint {
        _mint(to, amount);
    }
}
