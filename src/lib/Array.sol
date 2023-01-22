// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library Array {
    function check(address[] memory arr, address item) public pure returns (bool) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == item) {
                return true;
            }
        }
        return false;
    }

    function remove(address[] storage arr, uint256 index) public {
        require(index < arr.length);

        arr[index] = arr[arr.length - 1];
        arr.pop();
    }
}
