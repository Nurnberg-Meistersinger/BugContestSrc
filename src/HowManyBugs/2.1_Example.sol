// SPDX-License-Identifier: MIT

/* --------------------------------------------------------- */
// (1) Reentrancy in withdrawAll();
// Description: function is susceptible to reentrancy attack as it transfers funds before updating the balance.
/* --------------------------------------------------------- */
// (2) No Access control in withdrawAll();
// Description: function lacks proper access control, allowing it to be called by anyone, potentially leading to funds being stolen from the contract.
/* --------------------------------------------------------- */
// (3) Hardcoded gas amount in bankInternalTransfer();
// Description: function has a hardcoded gas(2100), which will break the contract execution if opcodes gas price will change in the future updates.
/* --------------------------------------------------------- */
// (4) Incorrect bitwise shift in bankInternalTransfer();
// Description: function utilizes inline assembly with incorrect implementation of bitwise shift.
/* --------------------------------------------------------- */
// (5) Unchecked data length in bankInternalTransfer();
// Description: function does not check the length of data being transferred along with the transaction.
/* --------------------------------------------------------- */

pragma solidity 0.8.0;

contract VulnerableBank {
    mapping(address => uint256) public balances;
    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit value must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    function withdrawAll() public {
        uint256 amount = balances[msg.sender];
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");
        balances[msg.sender] = 0;
    }

    function bankInternalTransfer(address _to, uint256 _amount, bytes32 _txData) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance.");
        balances[msg.sender] -= _amount;
        bytes memory data = abi.encodePacked(_txData);
        uint256 _dataLength = data.length;

        assembly {
            if iszero(call(2100, _to, _amount, add(data, 32), _dataLength, 0, 0)) {
                revert(0, 0)
            }
        }

        balances[_to] += _amount;
    }
}