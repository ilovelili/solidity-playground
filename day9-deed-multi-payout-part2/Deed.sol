// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Deed {
    address public lawyer;
    address payable public beneficiary;
    uint public earliest;
    uint public amount;
    uint constant public PAYOUTS = 10;
    uint constant public INTERVAL = 10;
    uint public paidPayouts;
    
    constructor(address _lawyer, address payable _beneficiary, uint _fromNow) payable {
        lawyer = _lawyer;
        beneficiary = _beneficiary;
        earliest = block.timestamp + _fromNow;
        amount = msg.value / PAYOUTS;
    }
    
    function withdraw() public {
        require(msg.sender == beneficiary, "beneficiary only");
        require(block.timestamp >= earliest, "too early");
        require(paidPayouts < PAYOUTS);
        
        uint elligiblePayouts = (block.timestamp - earliest) / INTERVAL;
        uint duePayouts = elligiblePayouts - paidPayouts;
        duePayouts = duePayouts + paidPayouts > PAYOUTS ? PAYOUTS - paidPayouts : duePayouts;
        paidPayouts += duePayouts;
        beneficiary.transfer(duePayouts * amount);
    }
    
}