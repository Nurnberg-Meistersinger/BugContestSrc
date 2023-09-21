// SPDX-License-Identifier: MIT
// Unsecure source of randomness

pragma solidity 0.8.0;

contract WatchThisCode {
    bytes32 sealedSeed;
    bool seedSet = false;
    bool betsClosed = false;
    bool betMade = false;
    uint storedBlockNumber;
    address public trustedParty;

    constructor() {
	    trustedParty = msg.sender;
    }

    function setSealedSeed(bytes32 _sealedSeed) public {
        require(!seedSet);
        require(msg.sender == trustedParty);
        betsClosed = true;
        sealedSeed = _sealedSeed;
        storedBlockNumber = block.number + 1;
        seedSet = true;
    }

    function bet() public {
        require(!betsClosed);
        /*Some betting logic here*/
        betMade = true;
    }

    function reveal(bytes32 _seed) public {
        require(seedSet);
        require(betMade);
        require(storedBlockNumber < block.number);
        bytes32 keccakArgs = keccak256(abi.encodePacked(msg.sender, _seed));
        require(keccakArgs == sealedSeed);
        uint random = uint(keccak256(abi.encodePacked(_seed, blockhash(storedBlockNumber))));
        /*Some logic for usage of random number here*/
        seedSet = false;
        betsClosed = false;
    }
}