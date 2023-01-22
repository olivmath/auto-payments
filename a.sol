// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library Array {
    function check(address[] memory arr, address item)
        public
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == item) {
                return true;
            }
        }
        return false;
    }
}

abstract contract Events {

event NewEmployee(address employee, uint256 salary, uint256 nextPayment);
event NewSalary(address employee, uint256 newSalary);
event EmployeeRemoved(address employee);
event Payed(address employee, uint256 salary);
}

contract Storage is Events {
    using Array for address[];
    address internal owner;

    struct Employee {
        uint256 salaryAmount;
        uint256 nextPayment;
        bool active;
    }
    mapping(address => Employee) mappingOfEmployees;
    address[] internal _employees;

    constructor() {
        owner = msg.sender;
    }
}

abstract contract Auth is Storage {
    constructor() Storage() {}
}

abstract contract Manage is Auth {
    constructor() Auth() {

    }

    function add(address employeeAddress, uint256 salaryAmount)
        public
    {
        require(!_employees.check(employeeAddress), "Employee already added");
        uint256 _nextPayment = nextPayment();
        _employees.push(employeeAddress);
        mappingOfEmployees[employeeAddress] = Employee(
            salaryAmount * 10e17,
            _nextPayment,
            true
        );

        emit NewEmployee(employeeAddress, salaryAmount, _nextPayment);
    }

    function removeEmployee(address employeeAddress) public {
        // onlyOwner(msg.sender);
        // require(_employees.check(employeeAddress), "Employee not exists");
        delete (mappingOfEmployees[employeeAddress]);

        emit EmployeeRemoved(employeeAddress);
    }

    function edit(address employeeAddress, uint256 newSalary) public {
        // require(_employees.check(employeeAddress), "Employee not exists");
        mappingOfEmployees[employeeAddress].salaryAmount = newSalary * 10e17;

        emit NewSalary(employeeAddress, newSalary);
    }

    function salary(address employeeAddress) public view returns (uint256) {
        return mappingOfEmployees[employeeAddress].salaryAmount;
    }

    function nextPayment(address employeeAddress)
        public
        view
        returns (uint256)
    {
        return mappingOfEmployees[employeeAddress].nextPayment;
    }

    function monthInBlocks() internal pure returns (uint256) {
        uint256 monthInDays = 30;
        uint256 dayInHours = 24;
        uint256 hourInSeconds = 3600;
        uint256 blockInSeconds = 15;

        return (monthInDays * dayInHours * hourInSeconds) / blockInSeconds;
    }

    function nextPayment() internal view returns (uint256) {
        return block.number + monthInBlocks();
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    function totalCost() public view returns (uint256) {
        uint256 totalCust = 0;
        for (uint256 i = 0; i < _employees.length; i++) {
            totalCust += mappingOfEmployees[_employees[i]].salaryAmount;
        }
        return totalCust;
    }

    function employees() public view returns (address[] memory) {
        return _employees;
    }

        function verifyPayment(address employee) internal view returns (bool) {
        return
            block.number >= mappingOfEmployees[employee].nextPayment &&
            mappingOfEmployees[employee].salaryAmount > 0;
    }
           function deposit() public payable {
        // onlyOwner(msg.sender);
    }
}

contract Base is Manage {
    constructor() Manage() {}
}

contract AutoPayments is Base {
    constructor() Base() {}
    function pay() public payable {
        for (uint256 i = 0; i < _employees.length; i++) {
            address payable employee = payable(_employees[i]);
            if (verifyPayment(employee) == true) {
                uint256 amount = mappingOfEmployees[employee].salaryAmount;
                require(
                    balance() > amount,
                    "Contract not have balance for pay employee"
                );
                (bool sent, bytes memory _data) = employee.call{value: amount}(
                    ""
                );
                require(sent, "Failed to send eth to employee");

                mappingOfEmployees[employee].nextPayment += monthInBlocks();

                emit Payed(employee, amount);
            } else {}
        }
    }
}
