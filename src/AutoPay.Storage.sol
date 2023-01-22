// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Array} from "./lib/Array.sol";
import {Events} from "./AutoPay.Events.sol";

contract Storage is Events {
    using Array for address[];
    address internal owner;

    struct Employee {
        uint256 salaryAmount;
        uint256 nextPayment;
        bool active;
    }
    mapping(address => Employee) mappingOfEmployees;
    address[] internal _employees;

    constructor() {
        owner = msg.sender;
    }
}
