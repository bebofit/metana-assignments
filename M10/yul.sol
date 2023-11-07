pragma solidity ^0.8.4;

contract BitWise {
    // count the number of bit set in data.  i.e. data = 7, result = 3
    function countBitSet(uint8 data) public pure returns (uint8 result) {
        for (uint i = 0; i < 8; i += 1) {
            if (((data >> i) & 1) == 1) {
                result += 1;
            }
        }
    }

    function countBitSetAsm(uint8 data) public pure returns (uint8 result) {
        // replace following line with inline assembly code
        assembly {
            for {
                let i := 0
            } lt(i, 8) {
                i := add(i, 1)
            } {
                let s := shr(i, data)
                let r := and(s, 1)
                if eq(r, 1) {
                    result := add(result, 1)
                }
            }
        }
    }
}

// Add following test cases for String contract:
// charAt("abcdef", 2) should return 0x6300
// charAt("", 0) should return 0x0000
// charAt("george", 10) should return 0x0000

contract String {
    function charAt(
        string memory input,
        uint index
    ) public view returns (bytes2) {
        bytes2 a;
        assembly {
            // this is where the len of string located
            let len := mload(0x80)
            let q := and(not(iszero(len)), lt(index, len))
            if eq(q, 1) {
                // 0xa0 where content of string is + index to get starting position
                let loc := add(0xa0, index)
                a := mload(loc)
            }
        }
        return a;
    }
}
