// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDToken is ERC20 {
    mapping(address => bool) private _blacklisted;
    address private _owner;
    uint total = 1000000 * 10 ** 18;

    constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        _mint(msg.sender, initialSupply);
        _owner = msg.sender;
    }

    function buyToken() public payable returns (bool) {
        require(msg.value == 1 ether, "user must pay exactly one eth");
        require(totalSupply() < total, "sale passed, better luck next time");
        _mint(msg.sender, 1000 * 10 ** 18);
        return true;
    }

    function withdraw() public {
        require(msg.sender == _owner, "only owner");
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw; contract balance empty");

        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
