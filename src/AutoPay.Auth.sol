// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Array, Storage} from "./AutoPay.Storage.sol";

error EmployeeNotExists(address employee);
error EmployeeExists(address employee);
error Unauthorized(address investor);
error NoEthers();

abstract contract Auth is Storage {
    using Array for address[];

    constructor(string memory _companyName, string memory _description, uint256 _locktime) Storage(_companyName, _description, _locktime) {}

    function onlyOwner(address user) internal view {
        if (user != owner) {
            revert Unauthorized(user);
        }
    }

    function checkEmployee(address employee) private view returns (bool) {
        return _employees.check(employee);
    }

    function checkEmployeeNotExists(address employee) internal view {
        if (checkEmployee(employee)) {
            revert EmployeeNotExists(employee);
        }
    }

    function checkEmployeeExists(address employee) internal view {
        if (!checkEmployee(employee)) {
            revert EmployeeExists(employee);
        }
    }

    function checkZeroBalance() internal view {
        if (address(this).balance == 0) {
            revert NoEthers();
        }
    }

    function checkPayEmployee(address employee) internal view returns (bool) {
        bool A = address(this).balance >= mappingOfEmployees[employee].salary + 0.1 ether;
        bool B = mappingOfEmployees[employee].nextPayment <= block.number;
        bool C = mappingOfEmployees[employee].active == true;
        return A && B && C;
    }
}
