// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {AutoPayments} from "../src/AutoPay.sol";
import {Test} from "forge-std/Test.sol";
import {Utils} from "./Utils.sol";

contract BaseSetup is Test, Utils {
    AutoPayments ap;

    address[] users;
    address owner;
    address alise;
    address bob;

    function setUp() public virtual {
        Utils utils = new Utils();
        users = utils.createUsers(3);

        owner = users[0];
        vm.label(owner, "Owner");
        bob = users[1];
        vm.label(bob, "Bob");
        alise = users[2];
        vm.label(alise, "Alise");

        vm.prank(owner);
        ap = new AutoPayments();
    }
}
