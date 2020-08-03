// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract EtherWallet {
    address payable public owner;
    
    // Prior to version 0.7.0, you had to specify the visibility of constructors as either internal or public.
    constructor(address payable _owner) {
        owner = _owner;
    }
    
    // TBD
    function deposit() payable public {}
    
    function send(address payable to, uint256 amount) public {
        require(msg.sender == owner, "invalid sender");
        to.transfer(amount);
    }
    
    function balanceOf() public view returns (uint256) {
        return address(this).balance;
    }
}