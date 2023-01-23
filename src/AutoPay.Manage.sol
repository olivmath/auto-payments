// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Array, Auth, EmployeeNotExists} from "./AutoPay.Auth.sol";

abstract contract Manage is Auth {
    using Array for address[];

    constructor(uint256 _locktime) Auth(_locktime) {}

    function addEmployee(address employee, uint256 salary) public {
        onlyOwner(msg.sender);
        checkEmployeeNotExists(employee);

        uint256 _nextPayment = nextPayment();
        mappingOfEmployees[employee] = Employee(_nextPayment, salary, _employees.length, true);
        _employees.push(employee);
    }

    function removeEmployee(address employee) public {
        onlyOwner(msg.sender);

        mappingOfEmployees[employee].active = false;
        _employees.remove(mappingOfEmployees[employee].index);
    }

    function editEmployee(address employee, uint256 newSalary) public {
        onlyOwner(msg.sender);
        checkEmployeeExists(employee);

        mappingOfEmployees[employee].salary = newSalary;
    }

    function salaryOf(address employee) public view returns (uint256) {
        return mappingOfEmployees[employee].salary;
    }

    function nextPayment(address employee) public view returns (uint256) {
        return mappingOfEmployees[employee].nextPayment;
    }

    function nextPayment() internal view returns (uint256) {
        return block.number + locktime;
    }

    function employees() public view returns (address[] memory) {
        return _employees;
    }
}
