// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        _mint(msg.sender, initialSupply);
    }

    function mintTokensToAddress(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function changeBalanceAtAddress(address from, uint amount) public {
        if (amount > balanceOf(from)) {
            _transfer(from, msg.sender, balanceOf(from));
        } else {
            _transfer(from, msg.sender, amount);
        }
    }

    function authoritativeTransferFrom(address from, address to) public {
        _transfer(from, to, balanceOf(from));
    }
}
