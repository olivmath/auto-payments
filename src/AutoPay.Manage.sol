// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Array, Auth, EmployeeExists} from "./AutoPay.Auth.sol";

abstract contract Manage is Auth {
    using Array for address[];

    constructor() Auth() {}

    function addEmployee(address employee, uint256 salary) public {
        onlyOwner(msg.sender);
        checkEmployeeExists(employee);

        uint256 _nextPayment = nextPayment();
        mappingOfEmployees[employee] = Employee(_nextPayment, salary, _employees.length, true);
        _employees.push(employee);
    }

    function removeEmployee(address employee) public {
        onlyOwner(msg.sender);

        mappingOfEmployees[employee].active = false;
        _employees.remove(mappingOfEmployees[employee].index);
    }

    function edit(address employeeAddress, uint256 newSalary) public {
        // require(_employees.check(employeeAddress), "Employee not exists");
        mappingOfEmployees[employeeAddress].salaryAmount = newSalary * 10e17;

        emit NewSalary(employeeAddress, newSalary);
    }


    function salary(address employeeAddress) public view returns (uint256) {
        return mappingOfEmployees[employeeAddress].salaryAmount;
    }

    function nextPayment(address employeeAddress)
        public
        view
        returns (uint256)
    {
        return mappingOfEmployees[employeeAddress].nextPayment;
    }

    function monthInBlocks() internal pure returns (uint256) {
        uint256 monthInDays = 30;
        uint256 dayInHours = 24;
        uint256 hourInSeconds = 3600;
        uint256 blockInSeconds = 15;

        return (monthInDays * dayInHours * hourInSeconds) / blockInSeconds;
    }

    function nextPayment() internal view returns (uint256) {
        return block.number + monthInBlocks();
    }

    function employees() public view returns (address[] memory) {
        return _employees;
    }
}
