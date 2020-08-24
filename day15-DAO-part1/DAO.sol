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
    mapping(address => bool) public investors;
    mapping(address => uint256) public shares;
    
    uint256 public totalShares;
    uint256 public availableFunds;
    uint256 public contributionEnd;
    
    constructor(uint256 contributionTime) {
        contributionEnd = block.timestamp + contributionTime;
    }
    
    function contribute() external payable {
        require(block.timestamp < contributionEnd, "Cannot contribute after contribute end");
        investors[msg.sender] = true;
        shares[msg.sender] += msg.value;
        totalShares += msg.value;
        availableFunds += msg.value;
    }
    
}