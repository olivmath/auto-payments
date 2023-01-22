// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Array, Storage} from "./AutoPay.Storage.sol";

error EmployeeNotExists(address employee);
error EmployeeExists(address employee);
error Unauthorized(address investor);
error NoEthers();

abstract contract Auth is Storage {
    using Array for address[];

    constructor() Storage() {}

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
}
