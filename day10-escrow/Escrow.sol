// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Escrow {
    enum State {AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE}
    
    address public payer;
    address payable public payee;
    address public lawyer;
    uint256 public amount;
    State public currState;
    
    constructor(address _payer, address payable _payee, uint256 _amount) {
        payer = _payer;
        payee = _payee;
        amount = _amount;
        lawyer = msg.sender;
        
        currState = State.AWAITING_PAYMENT;
    }
    
    //  function with the payable modifier can receive funds. 
    function deposit() payable public {
        require(msg.sender == payer, "Sender must be the payer");
        require(currState == State.AWAITING_PAYMENT, "Already paid");
        require(address(this).balance <= amount, "Cant send more than escrow amount");
        currState = State.AWAITING_DELIVERY;
    }
    
    function release() public {
        require(address(this).balance == amount, 'cannot release funds before full amount is sent');
        require(currState == State.AWAITING_DELIVERY, "Cannot confirm delivery");
        require(msg.sender == lawyer, "only lawyer can release funds");
        payee.transfer(amount);
        currState = State.COMPLETE;
    }
    
    function balanceOf() view public returns (uint256) {
        return address(this).balance;
    }
    
}