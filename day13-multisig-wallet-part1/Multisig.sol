// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Wallet {
    address[] public approvers;
    uint256 public quorum;
    
    struct Transfer {
        uint256 id;
        uint256 amount;
        address payable to;
        uint256 approvals;
        bool sent;
    }
    
    mapping(uint256 => Transfer) transfers;
    uint256 nextId;
    
    constructor(address[] memory _approvers, uint256 _quorum) payable {
        approvers = _approvers;   
        quorum = _quorum;
    }
    
    function createTransfer(uint256 amount, address payable to) external {
        transfers[nextId] = Transfer(
            nextId,
            amount,
            to,
            0,
            false
        );
        
        nextId++;
    }
    
}