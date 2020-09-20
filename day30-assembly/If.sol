// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

// assembly tutorial: https://medium.com/@jeancvllr/solidity-tutorial-all-about-assembly-5acdfefde05c
// https://solidity.readthedocs.io/en/v0.6.2/yul.html#evm-dialect
contract If {
    function ifInSolidity(uint256 _data) pure external returns (uint256) {
        if(_data == 1) return 10;
        if (_data == 2) return 20;
        return 100;
    }
    
    // assembly supports switch case
    function ifInAssembly(uint256 _data) pure external returns (uint256 ret) {
        assembly {
            switch _data
            case 1 {
                ret := 10
            }
            case 10 {
                ret := 20
            }
            default {
                ret := 100
            }
        }
    }
}