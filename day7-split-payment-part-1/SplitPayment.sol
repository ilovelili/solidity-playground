// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract SplitPayment {
    function send(address payable[] memory to, uint256[] memory amount) payable public {
        require(to.length == amount.length, "param length mismatch");
        for (uint256 i = 0; i < to.length; i++) {
            to[i].transfer(amount[i]);
        }
    }
}