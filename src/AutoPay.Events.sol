// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract Events {
    event NewEmployee(address employee, uint256 salary, uint256 nextPayment);
    event NewSalary(address employee, uint256 newSalary);
    event EmployeeRemoved(address employee);
    event Payed(address employee, uint256 salary);
}
