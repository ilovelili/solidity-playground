// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Voting {
    mapping(address => bool) voters;
    
    struct Candidate {
        uint256 id;
        string name;
        uint256 votes;
    }
    
    struct Ballot {
        uint256 id;
        string name;
        Candidate[] candidates;
        uint256 end;
    }
    
    mapping(uint256 => Ballot) ballots;
    uint256 nextBallotId;
    address public admin;
    
    constructor() {
        admin = msg.sender;
    }
    
    // calldata must be used when declaring an external function
    // https://www.c-sharpcorner.com/article/storage-and-memory-data-locations/
    // calldata is memory allocated by caller, memory is memory allocated by callee
    function addVoters(address[] calldata _voters) external {
        for(uint256 i = 0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
        }
    }
    
}