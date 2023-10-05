// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDToken is ERC20 {
    address private _owner;

    constructor(uint256 initialSupply) ERC20("BuyToken", "BT") {
        _owner = msg.sender;
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    function mintTokensToAddress(address to, uint256 amount) public {
        require(msg.sender == _owner, "not authorized");
        _mint(to, amount * 10 ** decimals());
    }
}
