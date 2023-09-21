// SPDX-License-Identifier: MIT
/* https://consensys.github.io/smart-contract-best-practices/known_attacks/#dos-with-unexpected-revert */

pragma solidity 0.8.0;

contract Refunder {
 address payable[] public refundAddresses;
 mapping (address => uint) public refunds;

 constructor(address _addrOwner, address _addrTest) {
    refundAddresses.push(payable(_addrOwner));
    refundAddresses.push(payable(_addrTest));
 }

 function refundAll() public {
    for(uint x; x < refundAddresses.length; x++) { // arbitrary length iteration based on how many addresses participated
        require(refundAddresses[x].send(refunds[refundAddresses[x]])); // doubly bad, now a single failure on send will hold up all funds
        }
    }
}