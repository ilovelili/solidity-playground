// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract Voting {
    mapping(address => bool) public voters;
    
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
    
    function addVoters(address[] calldata _voters) external onlyAdmin() {
         for(uint256 i = 0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
        }
    }
    
    function createBallot(string calldata name, string[] calldata _candidates, uint256 offset) external onlyAdmin() {
        ballots[nextBallotId].id = nextBallotId;
        ballots[nextBallotId].name = name;
        ballots[nextBallotId].end = block.timestamp + offset;
        
        for(uint256 i = 0; i < _candidates.length ; i++) {
            ballots[nextBallotId].candidates.push(Candidate(i, _candidates[i], 0));
        }
        nextBallotId++;
    }
    
    modifier onlyAdmin() {
        require(admin == msg.sender, "only admin allowed");
        _;
    }
}