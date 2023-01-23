// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Events} from "./AutoPay.Events.sol";
import {Array} from "./lib/Array.sol";

contract Storage is Events {
    string public companyName;
    string public description;
    address internal owner;
    uint256 internal locktime;

    struct Employee {
        uint256 nextPayment;
        uint256 salary;
        uint256 index;
        bool active;
    }

    mapping(address => Employee) mappingOfEmployees;
    address[] internal _employees;

    constructor(string memory _companyName, string memory _description, uint256 _locktime) {
        companyName = _companyName;
        description = _description;
        locktime = _locktime;
        owner = msg.sender;
    }
}
