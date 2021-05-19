pragma solidity 0.6.0;

contract Escrow {
    
    address payable public buyer;
    address payable public seller;
    address payable private escrow;
    mapping(address => uint) amount;
    
    enum State {
        waiting_for_payment, waiting_for_delivery, complete
    }
    
    State public state;
    
    modifier instate(State expected_state) {
        require (state == expected_state);
        _;
    }
    
    modifier onlyBuyer() {
        require (msg.sender == buyer || msg.sender == escrow);
        _;
    }
    
    modifier onlySeler() {
        require (msg.sender == seller);
        _;
    }
    
    constructor(address payable _buyer,
                address payable _seller) public {
                    
                    escrow = msg.sender;
                    buyer = _buyer;
                    seller = _seller;
                    state = State.waiting_for_payment;
    }
    
    function confirm_payment() onlyBuyer instate(State.waiting_for_payment) public payable {
        state = State.waiting_for_delivery;
    }
    
    function confirm_delivery() onlyBuyer instate(State.waiting_for_delivery) public {
        seller.transfer(address(this).balance);
        state = State.complete;
    }
    
    function return_payment() onlySeler instate(State.waiting_for_delivery) public {
        buyer.transfer(address(this).balance);
    }
    
}