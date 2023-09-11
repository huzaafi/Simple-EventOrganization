// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;

contract EventOrganization {
    struct Event {
        address manager;
        string eventName;
        uint price;
        uint startDate;
        uint availableTickets;
        uint remainingTickets;
    }

    //point the struct event no
    mapping (uint => Event) public events;
    

    //Points to which address has tickets for which event.
    mapping (address => mapping(uint => uint)) public tickets; 

    //address create event
    function createEvent(string memory _eventName, uint _price, uint _startDate, uint _availableTickets) external {
        uint eventNo; // increase struct event number
        require(_startDate > block.timestamp, "Date is wrong");
        require(_availableTickets > 0, "You have to write number of tickets for event");
        events[eventNo] = Event(msg.sender, _eventName, _price, _startDate, _availableTickets, _availableTickets);
        eventNo++;
    }


    event ticketBuying (address, string eventName, uint price, uint totalPrice);

    modifier buyTicketsRequire(uint id, uint noOfTickets) {
        require(events[id].startDate > 0, "Event does nnot exist");
        require(events[id].startDate > block.timestamp, "Event ended");
        require(events[id].availableTickets > noOfTickets, "Not enough Tickets");
        require(msg.value >= (events[id].price * noOfTickets), "Insuficient Balance");
        _;
    }

    //payable function to buy tickets of exist event
    function buyTickets(uint id, uint noOfTickets) public payable buyTicketsRequire(id, noOfTickets) {
        Event storage _event = events[id];
        uint totalPrice = _event.price * noOfTickets;
        tickets[msg.sender][id] += noOfTickets;
        _event.remainingTickets -= noOfTickets;

        if (msg.value > totalPrice) { //if the sent amount is more than required then the rest of the amount will be resend to the sender
            uint returnExtra = msg.value - totalPrice;
            payable(msg.sender).transfer(returnExtra);
        }

        emit ticketBuying(msg.sender, _event.eventName, _event.price, totalPrice);
    }

    event ticketTransfer(address from, address to, uint noOfTickets);

    modifier transferTicketRequire(uint id, uint noOfTickets) {
        require(events[id].startDate > 0, "Event does not exist");
        require(events[id].startDate > block.timestamp, "Event ended");
        require(tickets[msg.sender][id] > 0 && tickets[msg.sender][id] >= noOfTickets, "You dont have enough tickets");
        _;
    }
  
    //if a person wants to send their tickets to someone.    
    function transferTickets(address to, uint id, uint noOfTickets) public transferTicketRequire(id, noOfTickets)  {
        
        tickets[to][id] += noOfTickets;
        tickets[msg.sender][id] -= noOfTickets;

        emit ticketTransfer(msg.sender, to, noOfTickets);
    }

}