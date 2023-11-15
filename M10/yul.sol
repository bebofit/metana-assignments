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

    function countBitSetAsm(uint8 data) public pure returns (uint8) {
        // replace following line with inline assembly code
        assembly {
            let result := 0
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
            mstore(0, result)
            return(0, 32)
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
    ) public pure returns (bytes2) {
        assembly {
            let offset := add(div(index, 32), 1)
            let desiredOffset := mul(offset, 32)
            let desiredIndex := mod(index, 32)
            let inputPtr := add(input, add(desiredOffset, desiredIndex))
            let
                mask
            := 0xff00000000000000000000000000000000000000000000000000000000000000
            mstore(inputPtr, and(mload(inputPtr), mask))
            return(inputPtr, 32)
        }
    }
}
