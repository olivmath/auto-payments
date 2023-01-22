// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./AutoPay.Base.sol";

contract AutoPayments is Base {
    constructor() Base() {}
    function pay() public payable {
        for (uint256 i = 0; i < _employees.length; i++) {
            address payable employee = payable(_employees[i]);
            if (verifyPayment(employee) == true) {
                uint256 amount = mappingOfEmployees[employee].salaryAmount;
                require(
                    balance() > amount,
                    "Contract not have balance for pay employee"
                );
                (bool sent, bytes memory _data) = employee.call{value: amount}(
                    ""
                );
                require(sent, "Failed to send eth to employee");

                mappingOfEmployees[employee].nextPayment += monthInBlocks();

                emit Payed(employee, amount);
            } else {}
        }
    }
}
