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
    uint256 public nextId;
    
    function createEvent(string calldata name, uint256 date, uint256 price, uint256 ticketCount) external {
        require(date > block.timestamp, "Event must be organized at a future time");
        require(ticketCount > 0, "Event must have at least one ticket");
        events[nextId] = Event(msg.sender, name, date, price, ticketCount, ticketCount);
        nextId++;
    }
    
    function buyTicket(uint256 id, uint256 amount) external payable {
        Event storage _event = events[id];
        // value are set to 0 / false if key doesnot 'exist'
        // https://ethereum.stackexchange.com/questions/13021/how-can-you-figure-out-if-a-certain-key-exists-in-a-mapping-struct-defined-insi
        require(_event.date != 0, "this event doesnot exist");
        require(block.timestamp < _event.date, "this event is no more active");
        require(msg.value >= (amount * _event.price), "not enough ether to buy tickets");
        require(_event.ticketRemaining >= amount, 'not enough ticket left');
        
        _event.ticketRemaining -= amount;
        tickets[msg.sender][id] += amount;
    }
    
}