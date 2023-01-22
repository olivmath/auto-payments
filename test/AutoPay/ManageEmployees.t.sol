// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {EmployeeExists, Unauthorized} from "../../src/AutoPay.Auth.sol";
import {AutoPayments} from "../../src/AutoPay.sol";
import {BaseSetup} from "../BaseSetup.sol";

contract ManageTest is BaseSetup {
    uint256 salaryAmount;

    function setUp() public virtual override {
        BaseSetup.setUp();
        salaryAmount = 100;
    }

    function test_that_an_unauthorized_user_try_added_new_employee() public {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector, bob));
        ap.addEmployee(bob, 10000);
    }

    function test_that_an_employee_can_be_added_to_the_contract() public {
        vm.prank(owner);
        ap.addEmployee(bob, salaryAmount);
        address[] memory employees = ap.employees();

        assertEq(employees.length, 1, "Employee not added");
        assertEq(employees[0], bob, "Wrong employee added");
        assertEq(ap.nextPayment(bob), 172801, "Payment not added");
    }

    function test_that_an_employee_cannot_be_added_twice() public {
        vm.startPrank(owner);

        ap.addEmployee(bob, salaryAmount);
        vm.expectRevert(abi.encodeWithSelector(EmployeeExists.selector, bob));
        ap.addEmployee(bob, salaryAmount);

        vm.stopPrank();
    }

    function test_that_an_employee_can_be_removed() public {
        vm.startPrank(owner);

        ap.addEmployee(bob, salaryAmount);
        ap.removeEmployee(bob);

        vm.stopPrank();
        address[] memory employees = ap.employees();

        assertEq(employees.length, 0, "Employee not removed");
    }

    function test_that_an_employee_can_have_their_salary_edited() public {
        vm.startPrank(owner);

        ap.addEmployee(bob, salaryAmount);
        uint256 newSalary = 200;
        ap.editEmployee(bob, newSalary);

        vm.stopPrank();

        assertEq(ap.salaryOf(bob), newSalary * 10e17, "Salary not edited");
    }
}
