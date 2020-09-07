// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Lottery {
    enum State {
        IDLE,
        BETTING
    }
    
    address payable[] players;
    address admin;
    uint256 houseFee;
    uint256 betSize;
    uint256 betCount;
    State currentState = State.IDLE;
    
    constructor(uint256 fee) {
        require(fee > 1 && fee < 99, "fee should be between 1 and 99");
        admin = msg.sender;
        houseFee = fee;
    }
    
    function createBet(uint256 _betCount, uint256 _betSize) external onlyAdmin() inState(State.IDLE) {
        betCount = _betCount;
        betSize = _betSize;
        currentState = State.BETTING;
    }
    
    function bet() external payable inState(State.BETTING) {
        require(msg.value == betSize, "can only bet exactly the bet size");
        players.push(msg.sender);
     
        if (players.length >= betCount) {
            uint256 winner = _randomModulo(betCount);
            players[winner].transfer((betSize * betCount) * (100 - houseFee) / 100);
            currentState = State.IDLE;
            delete players; // reset players
        }
    }
    
    function cancel() external onlyAdmin() inState(State.BETTING) {
        // this should be replaced with draw pattern
        for (uint256 i = 0; i < players.length; i++) {
            players[i].transfer(betSize);
        }
        
        delete players;
        currentState = State.IDLE;
    }
    
    function _randomModulo(uint256 modulo) view internal returns(uint256) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % modulo;
    }
    
    modifier onlyAdmin() {
        require(admin == msg.sender, "only admin allowed");
        _;
    }
    
    modifier inState(State state) {
        require(state == currentState, "invalud state");
        _;
    }
}