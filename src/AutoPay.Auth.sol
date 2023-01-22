// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Array, Storage} from "./AutoPay.Storage.sol";

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

    function checkEmployeeExists(address employee) internal view {
        if (_employees.check(employee)) {
            revert EmployeeExists(employee);
        }
    }

    function checkZeroBalance() internal view {
        if(address(this).balance == 0) {
            revert NoEthers();
        }
    }
}
