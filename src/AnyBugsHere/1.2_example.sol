// SPDX-License-Identifier: MIT
// Unexpected ecrecover Null Address
// https://github.com/kadenzipfel/smart-contract-vulnerabilities/blob/
// master/vulnerabilities/unexpected-ecrecover-null-address.md

pragma solidity 0.8.0;

contract WatchThisCode {
    address public ContractOwner;

    constructor() {
	    ContractOwner = msg.sender;
    }

    function setOwner(address newOwner, uint8 v, bytes32 r, bytes32 s) external {
	    address signer = ecrecover(generateHash(newOwner), v, r, s);
	    require(signer == ContractOwner);
	    ContractOwner = newOwner;
    }

    function generateHash(address _addr) internal pure returns (bytes32) {
        bytes32 newOwnerHash = keccak256(abi.encodePacked(_addr));
        return
            keccak256(
                abi.encodePacked(
                    newOwnerHash
                )
            );
    }
}