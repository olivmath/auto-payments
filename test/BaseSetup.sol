// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {AutoPayments} from "../src/AutoPay.sol";
import {Test} from "forge-std/Test.sol";

contract BaseSetup is Test {
    bytes32 internal nextUser = keccak256(abi.encodePacked("test test test test test test test test test test test junk"));

     function getNextUserAddress() private returns (address payable) {
        //bytes32 to address conversion
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }

    function createUsers(uint256 userNum) private returns (address payable[] memory) {
        address payable[] memory users = new address payable[](userNum);
        for (uint256 i = 0; i < userNum; i++) {
            address payable user = getNextUserAddress();
            vm.deal(user, 10000 ether);
            users[i] = user;
        }
        return users;
    }

    AutoPayments ap;

    address[] _users;
    address owner;
    address alice;
    address bob;

    function setUp() public virtual {
        _users = createUsers(3);

        owner = _users[0];
        bob = _users[1];
        alice = _users[2];

        vm.label(owner, "Owner");
        vm.label(alice, "alice");
        vm.label(bob, "Bob");

        vm.prank(owner);
        ap = new AutoPayments();
    }
}
