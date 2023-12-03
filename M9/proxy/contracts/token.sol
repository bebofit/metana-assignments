// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IStakeToken {
    function setMinter(address theMinter) external;

    function mintToken(address to, uint256 amount) external;
}

contract StakeToken is Initializable, ERC20Upgradeable {
    address private _owner;
    address minter;

    error NotAuthorized();

    function initialize(uint256 initialSupply) external initializer {
        __ERC20_init("STAKE", "STK");
        _owner = msg.sender;
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    modifier isOwner() {
        if (msg.sender != _owner) revert NotAuthorized();
        _;
    }

    modifier canMint() {
        if (msg.sender != _owner && msg.sender != minter) {
            revert NotAuthorized();
        }
        _;
    }

    function setMinter(address theMinter) public isOwner {
        minter = theMinter;
    }

    function mintToken(address to, uint256 amount) public canMint {
        _mint(to, amount);
    }
}
