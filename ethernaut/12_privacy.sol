// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Privacy {
    // slot 0
    bool public locked = true;
    // slot 1
    uint256 public ID = block.timestamp;
    // slot 2 -> 1 byte
    uint8 private flattening = 10;
    // slot 2 -> 1 byte
    uint8 private denomination = 255;
    // slot 2 -> 2 bytes
    uint16 private awkwardness = uint16(block.timestamp);
    // slot 3, slot 4, slot 5
    bytes32[3] private data;

    constructor(bytes32[3] memory _data) {
        data = _data;
    }

    function unlock(bytes16 _key) public {
        require(_key == bytes16(data[2]));
        locked = false;
    }
}

// using web3 data = ether.getStorageat(address, 5)
// data.slice(0, 34) // take first 16 bytes
// will return the key
// we send it to unlock() and that is it
