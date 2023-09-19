// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GLDToken is ERC20 {
    mapping(address => bool) private _blacklisted;
    address private _owner;

    constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        _mint(msg.sender, initialSupply);
        _owner = msg.sender;
    }

    function blackListAddress(address hacker) public {
        require(msg.sender == _owner, "must be authorized");
        _blacklisted[hacker] = true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        address owner = _msgSender();
        require(
            _blacklisted[owner] != true,
            "blacklisted address cant transfer money"
        );
        require(
            _blacklisted[from] != true,
            "blacklisted address cant transfer money"
        );
        require(
            _blacklisted[to] != true,
            "blacklisted address cant transfer money"
        );
        require(amount > 0, "amount cannot be zero");
    }
}
