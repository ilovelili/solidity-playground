// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Fibonacci {
    // external is cheaper than public
    function fibonacci(uint256 n) pure external returns (uint256) {
        if (n == 0) {
            return 0;
        }
        
        uint256 fi_1 = 1;
        uint256 fi_2 = 1;
        
        for (uint256 i = 0; i < n; i++) {
            uint256 fi = fi_1 + fi_2;
            fi_2 = fi_1;
            fi_1 = fi;
        }
        
        return fi_1;
    }
}