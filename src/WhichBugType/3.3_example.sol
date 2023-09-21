// SPDX-License-Identifier: MIT
/* http://blockchain.unica.it/projects/ethereum-survey/attacks.html#simpledao */

pragma solidity 0.8.0;

contract SimpleDAO {
  mapping (address => uint) public credit;
  address payable withdrawer;

  function donate(address _to) payable public{
    credit[_to] += msg.value;
  }

  function withdraw(uint _amount) public{
    if (credit[msg.sender]>= _amount) {
      require(withdrawer.send(_amount));
      credit[msg.sender]-=_amount;
    }
  }

  function queryCredit(address _to) view public returns(uint){
    return credit[_to];
  }
}