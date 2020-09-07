// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Lottery {
    enum State {
        IDLE,
        BETTING
    }
    
    address admin;
    uint256 houseFee;
    uint256 betCount;
    uint256 betSize;
    State currentState = State.IDLE;
    
    constructor(uint256 fee) {
        require(fee >= 1 && fee <= 99, "Fee should be between 1 and 99");
        admin = msg.sender;
        houseFee = fee;
    }
    
    function createBet(uint256 _betCount, uint256 _betSize) external onlyAdmin() inState(State.IDLE) {
        betCount = _betCount;
        betSize = _betSize;
        currentState = State.BETTING;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin allowed");
        _;
    }
    
    modifier inState(State state) {
        require(state == currentState, "invalid state");
        _;
    }
    
}