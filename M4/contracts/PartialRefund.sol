// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PartialRefund is ERC20 {
    address private immutable _owner;
    error NotAuth();
    error Forbidden(string reason);

    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert NotAuth();
        }
        _;
    }

    constructor() ERC20("Gold", "GLD") {
        _owner = msg.sender;
    }

    function buyToken() public payable returns (bool) {
        if (msg.value != 1 ether) {
            revert Forbidden("user must pay exactly one eth");
        }
        uint256 tokens = 1000 * 10 ** decimals();
        if (balanceOf(address(this)) >= tokens) {
            _transfer(address(this), msg.sender, tokens);
        } else {
            if (balanceOf(address(this)) > 0) {
                uint256 remainingTokens = (tokens - balanceOf(address(this)));
                _transfer(address(this), msg.sender, balanceOf(address(this)));
                _mint(msg.sender, remainingTokens);
            } else {
                _mint(msg.sender, tokens);
            }
        }
        return true;
    }

    function sellBack(uint tokens) public returns (bool) {
        uint256 realTokens = tokens * 10 ** decimals();
        if (balanceOf(msg.sender) < realTokens) {
            revert Forbidden("cannot sellback more than what you have");
        }
        if (realTokens == 0) {
            revert Forbidden("tokens must be bigger than zero");
        }
        _transfer(msg.sender, address(this), realTokens);
        uint256 val = (tokens * 0.5 ether);
        uint256 eth = val / 1000;
        if (eth > address(this).balance) {
            revert Forbidden("cannot pay more than you have");
        }
        payable(msg.sender).transfer(eth);
        return true;
    }

    function withdrawTokens() public onlyOwner {
        _transfer(address(this), _owner, balanceOf(address(this)));
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        if (amount == 0) {
            revert Forbidden("Nothing to withdraw; contract balance empty");
        }
        payable(_owner).transfer(amount);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
        buyToken();
    }
}
