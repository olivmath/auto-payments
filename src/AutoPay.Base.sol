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

    function deposit() public payable {}

    function withdraw() public {
        onlyOwner(msg.sender);
        checkZeroBalance();

        payable(msg.sender).transfer(address(this).balance);
    }
}
