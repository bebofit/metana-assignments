// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDToken is ERC20 {
    mapping(address => bool) private _blacklisted;
    address private _owner;
    uint total = 1000000;

    constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        _mint(msg.sender, initialSupply);
        _owner = msg.sender;
    }

    function buyToken() public payable returns (bool) {
        require(msg.value == 1 ether, "user must pay exactly one eth");
        require(totalSupply() < total, "sale passed, better luck next time");
        _mint(msg.sender, 1000);
        return true;
    }

    function sellBack(uint tokens) public returns (bool) {
        require(
            balanceOf(msg.sender) >= tokens,
            "cannot sellback more than what you have"
        );
        require(tokens > 0, "tokens must be bigger than zero");
        bool isApproved = approve(address(this), tokens);
        require(isApproved, "cannot sellback not approved");
        bool isTransfered = transfer(address(this), tokens);
        require(isTransfered, "cannot sell to contract");
        uint256 val = (tokens * 0.5 ether);
        uint256 eth = val / 1000;
        require(eth < address(this).balance, "cannot pay more than you have");
        (bool sent, ) = payable(msg.sender).call{value: eth}("");
        require(sent, "Failed to send Ether");
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
