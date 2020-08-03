// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract EtherWallet {
    function deposit() payable public {}
    
    function send(address payable to, uint256 amount) public {
        to.transfer(amount);
    }
}