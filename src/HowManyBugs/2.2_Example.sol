// SPDX-License-Identifier: MIT

/* --------------------------------------------------------- */
// (1) Front-Running possibility in makeOffer();
// Description: attacker can see the offer before it is mined into a block and make their own offer with a higher gas price.
/* --------------------------------------------------------- */
// (2) Missing input validation in makeOffer();
// Description: function does not validate whether the _to address is a contract, potentially allowing attackers to conduct attacks or perform malicious actions.
/* --------------------------------------------------------- */
// (3) Missing input validation in _execute();
// Description: function lacks input validation, which can lead to undefined behavior or errors.
/* --------------------------------------------------------- */
// (4) Untrusted delegatecall in _execute();
// Description: use of delegatecall poses a risk as it could lead to the execution of untrusted code that can alter the contract's state.
/* --------------------------------------------------------- */
// (5) Unsecured sensitive data in `accessToken` variable;
// Description: sensitive information such as access tokens should be stored off-chain securely.
/* --------------------------------------------------------- */
// (6) Reveal of confidential formula in calculateSecret();
// Description: confidential logic has not to be visible and should be executed off-chain.
/* --------------------------------------------------------- */

pragma solidity 0.8.0;

contract DealContract {
    address public owner;
    uint256 private accessToken = 801013;
    address payable public sellerContract;
    uint256 public bestOffer;
    address public bestOfferAddress;

    constructor(address payable _sellerContract) {
        owner = msg.sender;
        sellerContract = _sellerContract;
    }

    function makeOffer(uint256 _offer, address _offerContract, bytes memory _offerData) public payable returns (bool) {
        require(_offer > bestOffer, "There is already a better offer.");
        bestOffer = _offer;
        bestOfferAddress = msg.sender;
        _execute(_offerContract, _offerData);
        sellerContract.transfer(_offer);
        return true;
    }

    function updateAccessToken(uint256 _a, uint256 _b) public {
        require(owner == msg.sender);
        uint256 secret = _calculateSecret(_a, _b);
        if(secret < accessToken) {
            accessToken = secret;
        }
    }

    function _calculateSecret(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 result = _a * _b + _a / _b - _b;
        return result;
    }

    function _execute(address _target, bytes memory _data) internal {
        (bool success, ) = _target.delegatecall(_data);
        require(success, "Delegatecall failed.");
    }
}