// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./AutoPay.Base.sol";

contract AutoPayments is Base {
    constructor(string memory _companyName, string memory _description, uint256 _locktime) Base(_companyName, _description, _locktime) {}

    function pay() public payable {
        onlyOwner(msg.sender);
        for (uint256 i = 0; i < _employees.length; i++) {
            if (checkPayEmployee(_employees[i])) {
                _employees[i].call{value: mappingOfEmployees[_employees[i]].salary}("");
            }
        }
    }
}
