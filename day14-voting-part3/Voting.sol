// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract Voting {
    mapping(address => bool) public voters;
    mapping(uint256 => Ballot) ballots;
    mapping(address => mapping(uint => bool)) votes;
    
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
    
    uint256 nextBallotId;
    address public admin;
    
    constructor() {
        admin = msg.sender;
    }
    
    function addVoters(address[] calldata _voters) external onlyAdmin() {
        for (uint256 i = 0; i < _voters.length; i++) {
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
    
    function vote(uint256 ballotId, uint256 candidateId) external {
        require(voters[msg.sender], 'only voters can vote');
        require(!votes[msg.sender][ballotId], 'voter can only vote once for a ballot');
        require(block.timestamp < ballots[ballotId].end, 'can only vote until ballot end date');
        votes[msg.sender][ballotId] = true;
        ballots[ballotId].candidates[candidateId].votes++;
    }
    
    //If `pragma experimental ABIEncoderV2`
    function results(uint256 ballotId) view external returns(Candidate[] memory) {
        require(block.timestamp >= ballots[ballotId].end, 'cannot see the ballot result before ballot end');
        return ballots[ballotId].candidates;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }
}