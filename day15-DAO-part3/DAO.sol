// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

/**
 * DAO contract:
 * 1. Collects investors money (ether)
 * 2. Keep track of investor contributions with shares
 * 3. Allow investors to transfer shares
 * 4. allow investment proposals to be created and voted
 * 5. execute successful investment proposals (i.e send money)
 */
contract DAO {
    struct Proposal {
        uint256 id;
        string name;
        uint256 amount;
        address payable recipient;
        uint256 votes;
        uint256 end;
        bool executed;
    }
    
    mapping(address => bool) public investors;
    mapping(address => uint256) public shares;
    mapping(address => mapping(uint256 => bool)) public votes;
    mapping(uint256 => Proposal) public proposals;
    
    uint public totalShares;
    uint256 public availableFunds;
    uint256 public contributionEnd;
    uint256 public nextProposalId;
    uint256 public voteTime;
    uint256 public quorum;
    address public admin;
    
    constructor(
        uint256 contributionTime,
        uint256 _voteTime,
        uint256 _quorum
    ) {
        require(_quorum > 0 && _quorum < 100, 'quorum must be between 0 and 100');
        contributionEnd = block.timestamp + contributionTime;
        voteTime = _voteTime;
        quorum = _quorum;
        admin = msg.sender;
    }
    
    function contribute() payable external {
        require(block.timestamp < contributionEnd, 'cannot contribute after contributionEnd');
        investors[msg.sender] = true;
        shares[msg.sender] += msg.value;
        totalShares += msg.value;
        availableFunds += msg.value;
    }
    
    function redeemShare(uint256 amount) external onlyInvestors() {
        require(shares[msg.sender] >= amount, "insufficient amount");
        require(availableFunds >= amount, "not enough funds");
        availableFunds -= amount;
        shares[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }
    
    function transferShare(address to, uint256 amount) external onlyInvestors() {
        require(shares[msg.sender] >= amount, "insufficient amount");
        shares[to] = amount;
        shares[msg.sender] -= amount;
        investors[to] = true;
    }
    
    function createProposal(string calldata name, uint256 amount, address payable recipient) external onlyInvestors() {
        require(availableFunds >= amount, 'amount too big');
        proposals[nextProposalId] = Proposal(
          nextProposalId,
          name,
          amount,
          recipient,
          0,
          block.timestamp + voteTime,
          false
        );
        
        availableFunds -= amount;
        nextProposalId++;
    }
    
    function vote(uint proposalId) external onlyInvestors() {
        Proposal storage proposal = proposals[proposalId];
        require(votes[msg.sender][proposalId] == false, 'investor can only vote once for a proposal');
        require(block.timestamp < proposal.end, 'can only vote until proposal end date');
        votes[msg.sender][proposalId] = true;
        proposal.votes += shares[msg.sender];
    }
    
    modifier onlyInvestors() {
     require(investors[msg.sender] == true, 'only investors');
     _;
  }
    
    
    
    
    
}