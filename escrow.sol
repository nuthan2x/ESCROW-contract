//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.16;

contract escrow{

    address payable public escrow_AGENT;
    address payable public buyer;
    address payable public seller;
    uint public buyerprice;
    uint public askingprice;

    bool public BUYER_in;
    bool public SELLER_in;
    bool public seller_delivery_SUCCCESS;
    bool public buyer_refund_SUCCESS;

    enum State{ before_Initialize, awaiting_payment, awaiting_delivery,compeleted, buyer_withdrawn}
    State public ESCROW_state;

    modifier onlybuyer(){
        require(msg.sender == buyer);
        _;
    }

    modifier onlyescrow_AGENT(){
        require(msg.sender == escrow_AGENT);
        _;
    }

    constructor(address payable _buyer, address payable _seller){
        ESCROW_state = State.before_Initialize;
        escrow_AGENT = payable(msg.sender);
        askingprice = 0.01 ether;
        buyer = _buyer;
        seller = _seller;

    }

    //incase buyer sends funds to contract without calling the payment function
    receive() external payable{
        buyer_payment();
    }

    function contract_START_BUYER() public{
        require(ESCROW_state == State.before_Initialize,"cant initiate now");
        require(BUYER_in == false);  
        if(msg.sender == buyer){
            BUYER_in = true;
        }
    }
    function contract_START_SELLER() public{
        require(ESCROW_state == State.before_Initialize,"cant initiate now");
        require(SELLER_in == false);
        if(msg.sender == seller){
            SELLER_in = true;
        }
    }

    function ESCROW_START()public onlyescrow_AGENT{
         require(BUYER_in == true && SELLER_in == true,"buyer/seller not IN" );
         ESCROW_state = State.awaiting_payment;
    }

    function buyer_payment() payable public  onlybuyer {
        require(ESCROW_state == State.awaiting_payment,"cant pay now");

        buyerprice = msg.value;
        require(buyerprice == askingprice,"price mismatch");

        escrow_AGENT.transfer(buyerprice);
        ESCROW_state = State.awaiting_delivery;
        
    }

    function delivered() payable public  onlyescrow_AGENT{
        require(ESCROW_state == State.awaiting_delivery,"payment not yet made by buyer");

        payable(seller).transfer(askingprice);
        ESCROW_state = State.compeleted;

        seller_delivery_SUCCCESS = true;

    }

    function buyer_withdraw() payable public onlybuyer{
        require(ESCROW_state == State.awaiting_delivery,"not at this stage bruh");

        payable(buyer).transfer(buyerprice);

        ESCROW_state = State.buyer_withdrawn;
        buyer_refund_SUCCESS = true;
        

    }

}
