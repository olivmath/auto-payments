// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract Events {
    event NewEmployee(address employee, uint256 salary, uint256 nextPayment);
    event NewSalary(address employee, uint256 newSalary);
    event EmployeeRemoved(address employee);
    event Payed(address employee, uint256 salary);
}

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

contract Storage is Events {
    address internal owner;

    struct Employee {
        uint256 nextPayment;
        uint256 salary;
        uint256 index;
        bool active;
    }

    mapping(address => Employee) mappingOfEmployees;
    address[] internal _employees;

    constructor() {
        owner = msg.sender;
    }
}

error EmployeeExists(address employee);
error Unauthorized(address investor);

abstract contract Auth is Storage {
    using Array for address[];

    constructor() Storage() {}

    function onlyOwner(address user) internal view {
        if (user != owner) {
            revert Unauthorized(user);
        }
    }

    function checkEmployeeExists(address employee) internal view {
        if (_employees.check(employee)) {
            revert EmployeeExists(employee);
        }
    }
}

abstract contract Manage is Auth {
    using Array for address[];

    constructor() Auth() {}

    function addEmployee(address employee, uint256 salary) public {
        onlyOwner(msg.sender);
        checkEmployeeExists(employee);

        uint256 _nextPayment = nextPayment();
        mappingOfEmployees[employee] = Employee(_nextPayment, salary, _employees.length, true);
        _employees.push(employee);
    }

    function removeEmployee(address employee) public {
        onlyOwner(msg.sender);

        mappingOfEmployees[employee].active = false;
        _employees.remove(mappingOfEmployees[employee].index);
    }

    function editEmployee(address employee, uint256 newSalary) public {
        onlyOwner(msg.sender);

        mappingOfEmployees[employee].salary = newSalary * 10e17;
    }

    function salaryOf(address employee) public view returns (uint256) {
        return mappingOfEmployees[employee].salary;
    }

    function nextPayment(address employee) public view returns (uint256) {
        return mappingOfEmployees[employee].nextPayment;
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

    function employees() public view returns (address[] memory) {
        return _employees;
    }
}

contract Base is Manage {
    constructor() Manage() {}

    function verifyPayment(address employee) internal view returns (bool) {
        return block.number >= mappingOfEmployees[employee].nextPayment && mappingOfEmployees[employee].salary > 0;
    }

    function totalCost() public view returns (uint256) {
        uint256 totalCust = 0;
        for (uint256 i = 0; i < _employees.length; i++) {
            totalCust += mappingOfEmployees[_employees[i]].salary;
        }
        return totalCust;
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    function deposit() public payable {
        // onlyOwner(msg.sender);
    }
}

contract AutoPayments is Base {
    constructor() Base() {}

    function pay() public payable {
        for (uint256 i = 0; i < _employees.length; i++) {
            address payable employee = payable(_employees[i]);
            if (verifyPayment(employee) == true) {
                uint256 amount = mappingOfEmployees[employee].salary;
                require(balance() > amount, "Contract not have balance for pay employee");
                (bool sent,) = employee.call{value: amount}("");
                require(sent, "Failed to send eth to employee");

                mappingOfEmployees[employee].nextPayment += monthInBlocks();

                emit Payed(employee, amount);
            } else {}
        }
    }
}
