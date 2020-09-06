// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract EventContract {
    struct Event {
        address admin;
        string name;
        uint256 date;
        uint256 price;
        uint256 ticketCount;
        uint256 ticketRemaining;
    }
    
    mapping(uint256 => Event) public events;
    mapping(address => mapping(uint256 => uint256)) public tickets;
    
    uint256 nextId;
    
    function createTicket(string calldata name, uint256 date, uint256 price, uint256 ticketCount) external {
        require(date > block.timestamp, "event date must be a future time");
        require(ticketCount > 0, "there must be at least one ticket");
        events[nextId] = Event(msg.sender, name, date, price, ticketCount, ticketCount);
        nextId++;
    }
    
    function buyTicket(uint256 id, uint256 amount) external payable eventExists(id) eventActive(id) ticketRemains(id) {
        Event storage _event = events[id];
        require(msg.value >= _event.price * amount, "not enough ether to buy tickets");
        
        _event.ticketRemaining -= amount;
        tickets[msg.sender][id] += amount;
    }
    
    function transferTicket(uint256 id, uint256 amount, address to) external eventExists(id) eventActive(id) {
        require(tickets[msg.sender][id] >= amount, "not enough tickets to transfer");
        tickets[msg.sender][id] -= amount;
        tickets[to][id] += amount;
    }
    
    
    modifier eventExists(uint256 id) {
        require(events[id].date != 0, "event doesnot exist");
        _;
    }
    
    modifier eventActive(uint256 id) {
        require(events[id].date > block.timestamp, "ticker is no longer active");
        _;
    }
    
    modifier ticketRemains(uint256 id) {
        require(events[id].ticketRemaining > 0, "no ticket remaining");
        _;
    }
}