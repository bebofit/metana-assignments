// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PartialRefund is ERC20 {
    address private immutable _owner;
    uint256 constant TOTAL = 1e6 * 10 ** 18;
    error NotAuth();

    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert NotAuth();
        }
        _;
    }

    constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        uint256 tokens = initialSupply * 10 ** decimals();
        _mint(msg.sender, tokens);
        _owner = msg.sender;
    }

    function buyToken() public payable returns (bool) {
        require(msg.value == 1 ether, "user must pay exactly one eth");
        require(totalSupply() < TOTAL, "sale passed, better luck next time");
        uint256 tokens = 1000 * 10 ** decimals();
        if (balanceOf(address(this)) >= tokens) {
            _transfer(address(this), msg.sender, tokens);
        } else {
            _mint(msg.sender, tokens);
        }
        return true;
    }

    function sellBack(uint tokens) public returns (bool) {
        uint256 realTokens = tokens * 10 ** decimals();
        require(
            balanceOf(msg.sender) >= realTokens,
            "cannot sellback more than what you have"
        );
        require(realTokens > 0, "tokens must be bigger than zero");
        _transfer(msg.sender, address(this), realTokens);
        uint256 val = (tokens * 0.5 ether);
        uint256 eth = val / 1000;
        require(eth < address(this).balance, "cannot pay more than you have");
        payable(msg.sender).transfer(eth);
        return true;
    }

    function withdrawTokens() public onlyOwner {
        _transfer(address(this), _owner, balanceOf(address(this)));
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw; contract balance empty");
        payable(_owner).transfer(amount);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
        buyToken();
    }
}
