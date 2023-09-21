// SPDX-License-Identifier: MIT
/* https://consensys.github.io/smart-contract-best-practices/development-recommendations/
solidity-specific/complex-inheritance/ */

pragma solidity 0.8.0;

contract Final {
    uint public a;

    function FinalFunc(uint f) public {
        a = f;
    }
}

contract B is Final {
    int public fee;

    function BFunc(uint f) public {
        FinalFunc(f);
    }
    function setFee() public {
        fee = 3;
    }
}

contract C is Final {
    function CFunc(uint f) public {
        FinalFunc(f);
    }
    function setFee() public {
        fee = 5;
    }
}

contract A is B, C {
    function AFunc() public {
        BFunc(3);
        CFunc(5);
        setFee();
    }
}