// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Unauthorized, NoEthers} from "../../src/AutoPay.Auth.sol";
import {BaseSetup} from "../BaseSetup.sol";

contract EtherBalanceTest is BaseSetup {
    address private employee1;
    address private employee2;
    address private employee3;

    function setUp() public virtual override {
        BaseSetup.setUp();
        employee1 = address(1);
        employee2 = address(2);
        employee3 = address(3);

        vm.startPrank(owner);
        ap.deposit{value: 4000 ether}();
        ap.addEmployee(employee1, 100 ether);
        ap.addEmployee(employee2, 200 ether);
        ap.addEmployee(employee3, 300 ether);
        vm.stopPrank();
    }

    function test_that_employees_can_be_paid() public {
        vm.roll(1001);
        vm.prank(owner);
        ap.pay();
        uint256 employee1Balance = address(employee1).balance;
        uint256 employee2Balance = address(employee2).balance;
        uint256 employee3Balance = address(employee3).balance;
        assertEq(employee1Balance, 100 ether, "Employee 1 was not paid correctly");
        assertEq(employee2Balance, 200 ether, "Employee 2 was not paid correctly");
        assertEq(employee3Balance, 300 ether, "Employee 3 was not paid correctly");
    }
}
