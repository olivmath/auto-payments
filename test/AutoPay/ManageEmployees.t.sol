// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {EmployeeNotExists, EmployeeExists, Unauthorized} from "../../src/AutoPay.Auth.sol";
import {AutoPayments} from "../../src/AutoPay.sol";
import {BaseSetup} from "../BaseSetup.sol";

contract ManageTest is BaseSetup {
    uint256 salaryAmount;

    function setUp() public virtual override {
        BaseSetup.setUp();
    }

    function test_that_an_unauthorized_user_try_added_new_employee() public {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector, bob));
        ap.addEmployee(bob, 1);
    }

    function test_that_an_employee_can_be_added_to_the_contract_with_fix_salary(address newEmployee) public {
        uint256 salary = 12;
        vm.prank(owner);
        ap.addEmployee(newEmployee, salary);
        address[] memory employees = ap.employees();

        assertEq(employees.length, 1, "Employee not added");
        assertEq(employees[0], newEmployee, "Wrong employee added");
        assertEq(ap.salaryOf(newEmployee), 12, "Wrong salary added for employee");
        assertEq(ap.nextPayment(newEmployee), 172801, "Next payment not added");
    }

    function test_that_an_employee_can_be_added_to_the_contract(address newEmployee, uint256 salary) public {
        vm.prank(owner);
        ap.addEmployee(newEmployee, salary);
        address[] memory employees = ap.employees();

        assertEq(employees.length, 1, "Employee not added");
        assertEq(employees[0], newEmployee, "Wrong employee added");
        assertEq(ap.salaryOf(newEmployee), salary, "Wrong salary added for employee");
        assertEq(ap.nextPayment(newEmployee), 172801, "Next payment not added");
    }

    function test_that_an_employee_cannot_be_added_twice() public {
        vm.startPrank(owner);

        ap.addEmployee(bob, 100);
        vm.expectRevert(abi.encodeWithSelector(EmployeeNotExists.selector, bob));
        ap.addEmployee(bob, 100);

        vm.stopPrank();
    }

    function test_that_an_employee_can_be_removed(address newEmployee, uint256 salary) public {
        vm.startPrank(owner);

        ap.addEmployee(newEmployee, salary);
        ap.removeEmployee(newEmployee);

        vm.stopPrank();
        address[] memory employees = ap.employees();

        assertEq(employees.length, 0, "Employee not removed");
    }

    function test_that_an_employee_can_have_their_salary_edited(address newEmployee, uint256 salary) public {
        vm.assume(0 < salary && salary < 1000);
        vm.startPrank(owner);

        ap.addEmployee(newEmployee, salary);

        address[] memory employees = ap.employees();

        assertEq(employees[0], newEmployee, "Wrong employee added");
        assertEq(ap.salaryOf(newEmployee), salary, "Wrong salary added for employee");

        ap.editEmployee(newEmployee, salary * 2);
        assertEq(ap.salaryOf(newEmployee), salary * 2, "Salary not edited");

        vm.stopPrank();
    }

    function test_that_non_existent_employee_cannot_be_edited(address nonExistentEmployee) public {
        vm.startPrank(owner);
        address[] memory employees = ap.employees();


        assertEq(employees.length, 0, "Employee have more than one");
        vm.expectRevert(abi.encodeWithSelector(EmployeeExists.selector, nonExistentEmployee));
        ap.editEmployee(nonExistentEmployee, 200);
    }
}
