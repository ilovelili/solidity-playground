// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Fomo3D {
    enum State {
        INACTIVE,
        ACTIVE
    }
    
    State currentState = State.INACTIVE;
    address payable public king;
    uint public start;
    uint public end;
    uint public hardEnd;
    uint public pot;
    uint public initialKeyPrice;
    uint public totalKeys;
    address payable[] public keyHolders;
    mapping(address => uint) keys;
    
    function kickStart() external inState(State.INACTIVE) {
        currentState = State.ACTIVE;
        _createRound();
    }
    
    function _createRound() internal {
        for(uint256 i = 0; i < keyHolders.length; i++) {
            delete keys[keyHolders[i]];
        }
        
        delete keyHolders;
        totalKeys = 0;
        start = block.timestamp;
        end = block.timestamp + 30;
        hardEnd = block.timestamp + 86400;
        initialKeyPrice = 1 ether;
    }
    
    modifier inState(State state) {
        require(state == currentState, "invalid state");
        _;
    }
}