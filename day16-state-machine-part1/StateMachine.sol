// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract StateMachine {
    enum State {
        PENDING,
        ACTIVE,
        CLOSED
    }
    
    State public state = State.PENDING;
    
    uint256 public amount;
    uint256 public interest;
    uint256 public end;
    
    address payable public borrower;
    address payable public lender;
    
    constructor(
        uint256 _amount,
        uint256 _interest,
        uint256 _duration,
        address payable _borrower,
        address payable _lender    
    ) {
        amount = _amount;
        interest = _interest;
        end = block.timestamp + _duration;
        borrower = _borrower;
        lender = _lender;
    }
    
    function fund() payable external {
        require(msg.sender == lender, 'only lender can lend');
        require(address(this).balance == amount, 'can only lend the exact amount');
        borrower.transfer(amount);
    }
    
    function reimburse() payable external {
        require(msg.sender == borrower, 'only borrower can reimburse');
        require(msg.value == amount + interest, 'borrower need to reimburse exactly amount + interest');
        lender.transfer(amount + interest);
    }
}