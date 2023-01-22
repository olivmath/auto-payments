// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Manage} from "./AutoPay.Manage.sol";

contract Base is Manage {
    constructor() Manage() {}
}
