// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Deed {
    address public lawyer;
    address payable public beneficiary;
    uint256 public earliest;
    
    constructor(address _lawyer, address payable _beneficiary, uint256 _fromNow) {
        lawyer = _lawyer;
        beneficiary = _beneficiary;
        earliest = block.timestamp + _fromNow;
    }
    
    function withdraw() public payable {
        require(msg.sender == lawyer, "lawyer only");
        require(earliest <= block.timestamp, "too early");
        beneficiary.transfer(address(this).balance);
    }
}