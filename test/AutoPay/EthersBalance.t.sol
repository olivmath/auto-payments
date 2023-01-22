// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Unauthorized, NoEthers} from "../../src/AutoPay.Auth.sol";
import {BaseSetup} from "../BaseSetup.sol";

contract EtherBalanceTest is BaseSetup {
    uint256 salaryAmount;

    function setUp() public virtual override {
        BaseSetup.setUp();
        salaryAmount = 100;
    }

    function test_that_only_the_owner_can_withdraw() public {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector, bob));
        ap.withdraw();
    }

    function test_that_withdraw_should_transfer_all_ether() public {
        vm.startPrank(owner);
        ap.deposit{value: 2000 ether}();
        assertEq(owner.balance, 8000 ether, "Owner dont send Ether");
        assertEq(address(ap).balance, 2000 ether, "Contract dont receive Ether");

        ap.withdraw();
        assertEq(address(ap).balance, 0, "Contract dont transfer Ether");
        assertEq(owner.balance, 10000 ether, "Owner dont receive Ether");
    }

    function test_that_only_withdraw_with_ether_balance() public {
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(NoEthers.selector));
        ap.withdraw();
    }

    function test_that_total_cost_is_zero_when_no_employees_added() public {
        assertEq(ap.totalCost(), 0, "Total cost should be zero when no employees are added");
    }

    function test_that_total_cost_is_correctly_calculated() public {
        vm.startPrank(owner);

        ap.addEmployee(alice, salaryAmount);
        ap.addEmployee(bob, salaryAmount);

        vm.stopPrank();

        assertEq(ap.totalCost(), salaryAmount * 2, "Total cost is not correctly calculated");
    }

    function test_that_total_cost_is_correctly_calculated_after_removing_employee() public {
        vm.startPrank(owner);

        ap.addEmployee(bob, salaryAmount);
        ap.addEmployee(alice, salaryAmount);
        ap.removeEmployee(alice);

        vm.stopPrank();

        assertEq(ap.totalCost(), salaryAmount, "Total cost is not correctly calculated after removing employee");
    }
}
