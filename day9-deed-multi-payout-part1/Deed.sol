// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Deed {
    address public lawyer;
    address payable public beneficiary;
    uint256 public earliest;
    uint256 public amount;
    
    uint256 constant public PAYOUTS = 10;
    uint256 constant public INTERVAL = 10;
    uint256 public paidPayouts;
    
    constructor(address _lawyer, address payable _beneficiary, uint256 _fromNow) payable {
        lawyer = _lawyer;
        beneficiary = _beneficiary;
        earliest = block.timestamp + _fromNow;
        // payable needed for msg.value
        // Any function called that is not payable but a msg.value is sent will be reverted and fail
        amount = msg.value / PAYOUTS; 
    }
    
    function withdraw() public payable {
        require(msg.sender == lawyer, "lawyer only");
        require(block.timestamp >= earliest, "too early");
        beneficiary.transfer(address(this).balance);
    }
}