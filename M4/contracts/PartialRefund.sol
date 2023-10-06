// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PartialRefund is ERC20 {
    address private immutable _owner;
    uint256 constant TOTAL = 1e6 * 10 ** 18;
    event NoFunc(string message);

    constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        uint256 tokens = initialSupply * 10 ** decimals();
        _mint(msg.sender, tokens);
        _owner = msg.sender;
    }

    function buyToken() public payable returns (bool) {
        require(msg.value == 1 ether, "user must pay exactly one eth");
        require(totalSupply() < TOTAL, "sale passed, better luck next time");
        uint256 tokens = 1000 * 10 ** decimals();
        _mint(msg.sender, tokens);
        return true;
    }

    function sellBack(uint tokens) public returns (bool) {
        uint256 realTokens = tokens * 10 ** decimals();
        require(
            balanceOf(msg.sender) >= realTokens,
            "cannot sellback more than what you have"
        );
        require(realTokens > 0, "tokens must be bigger than zero");
        //NOTE: do i need to asset?
        approve(address(this), realTokens);
        //NOTE: do i need to asset?
        transfer(address(this), realTokens);
        uint256 val = (tokens * 0.5 ether);
        uint256 eth = val / 1000;
        //NOTE: do i need to asset? if so how can I test
        require(eth < address(this).balance, "cannot pay more than you have");
        payable(msg.sender).transfer(eth);
        return true;
    }

    function withdrawTokens() public {
        require(msg.sender == _owner, "only owner");
        _transfer(address(this), _owner, balanceOf(address(this)));
    }

    function withdraw() public {
        require(msg.sender == _owner, "only owner");
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw; contract balance empty");
        payable(_owner).transfer(amount);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
        emit NoFunc("no receive, Only from buying token");
    }

    // Fallback function is called when msg.data is not empty
    fallback() external payable {
        emit NoFunc("no fallback, Only from buying token");
    }
}
