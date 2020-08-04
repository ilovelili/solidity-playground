// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract SplitPayment {
    address owner;
    
    constructor (address _owner) {
        owner = _owner;
    }
    
    function send(address payable[] memory to, uint256[] memory amount) payable public onlyOwner {
        require(to.length == amount.length, "length mismatch");
        for (uint256 i = 0; i < to.length; i++) {
            to[i].transfer(amount[i]);
        }
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "invalid sender");
        _;
    }
    
}