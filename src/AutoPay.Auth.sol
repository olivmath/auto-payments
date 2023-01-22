// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Storage} from "./AutoPay.Storage.sol";

abstract contract Auth is Storage {
    constructor() Storage() {}
}