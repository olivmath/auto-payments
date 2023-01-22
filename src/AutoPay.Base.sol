// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Manage} from "./AutoPay.Manage.sol";

contract Base is Manage {
    constructor() Manage() {}

    function verifyPayment(address employee) internal view returns (bool) {
        return block.number >= mappingOfEmployees[employee].nextPayment && mappingOfEmployees[employee].salary > 0;
    }

    function totalCost() public view returns (uint256) {
        uint256 totalCust = 0;
        for (uint256 i = 0; i < _employees.length; i++) {
            totalCust += mappingOfEmployees[_employees[i]].salary;
        }
        return totalCust;
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    function deposit() public payable {
        // onlyOwner(msg.sender);
    }
}
