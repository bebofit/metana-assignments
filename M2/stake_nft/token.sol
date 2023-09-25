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

    constructor(uint256 initialSupply) ERC20("STAKE", "STK") {
        _owner = msg.sender;
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    modifier isOwner() {
        require(msg.sender == _owner, "only owner");
        _;
    }

    modifier canMint() {
        require(
            msg.sender == _owner || msg.sender == minter,
            "cannot mint token"
        );
        _;
    }

    function setMinter(address theMinter) public isOwner {
        minter = theMinter;
    }

    function mintToken(address to, uint256 amount) public canMint {
        _mint(to, amount);
    }
}
