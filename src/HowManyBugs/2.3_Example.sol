// SPDX-License-Identifier: MIT

/* --------------------------------------------------------- */
// (1) Timestamp dependence in updatePrice();
// Description: function uses price changes depending on the block timestamp, can be manipulated by miners.
/* --------------------------------------------------------- */
// (2) Floating point precision loss in buyToken();
// Description: Solidity does not support floating points, so the lost of precision results in ether loss.
/* --------------------------------------------------------- */
// (3) Reentrancy in buyToken();
// Description: Due to the fact that balances are updated after the transfer of tokens, the function may be subject to reentrancy.
/* --------------------------------------------------------- */
// (4) Possibility of `counterpartyToken` to be poisoned
// Description: if the implementation of the counterparty's ERC20 token is not disclosed, then the TransferFrom function may contain malicious logic.
/* --------------------------------------------------------- */
// (5) DoS with Block Gas Limit in mintAndSend();
// Description: if recipients list is too long, the transaction will fail because of block gas limit.
/* --------------------------------------------------------- */
// (6) Centralization threat in mindAndSend();
// Description: owner has an unlimited power to change the total supply of tokens.
/* --------------------------------------------------------- */

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VulnerableContract {
    address public owner;
    IERC20 public counterpartyToken;
    mapping(address => uint256) public balances;
    uint256 public price = 1 ether;
    uint256 public totalSupply;
    uint256 constant public supplyIncrement = 1000;

    constructor(address _counterpartyTokenAddress) {
        owner = msg.sender;
        counterpartyToken = IERC20(_counterpartyTokenAddress);
        totalSupply = supplyIncrement;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

function buyToken() external payable {
    updatePrice();
    uint256 amountToBuy = _countAmount(msg.value, price);
    require(amountToBuy <= balances[owner], "Not enough tokens available");
    require(counterpartyToken.allowance(msg.sender, address(this)) >= amountToBuy, "Token transfer not approved");
    counterpartyToken.transferFrom(msg.sender, address(this), amountToBuy);
    payable(owner).transfer(msg.value);
    balances[msg.sender] += amountToBuy;
    balances[owner] -= amountToBuy;
}

    function updatePrice() internal {
        if(block.timestamp % 2 == 0) {
            price = 2 ether;
        } else {
            price = 1 ether;
        }
    }

    function _countAmount(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mintAndSend(address[] memory recipients) onlyOwner external {
        totalSupply += supplyIncrement;
        uint256 amountToSend = supplyIncrement / recipients.length;
        for(uint i = 0; i < recipients.length; i++) {
            balances[recipients[i]] += amountToSend;
        }
    }
}