// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract IsContract {
    function isContract(address addr) view external returns(bool) {
        uint256 codeLength;
        // https://solidity-jp.readthedocs.io/ja/latest/assembly.html
        assembly {codeLength := extcodesize(addr)}
        return codeLength > 0;
    }
}