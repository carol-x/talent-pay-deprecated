// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9;

contract Payroll {
    uint public payPeriod;
    address payable public owner;
    uint public totalAmount; 
    mapping(address => uint) public latestTime; 
    mapping(address => uint) public eachPayAmount;
    mapping(address => uint) public paymentCount;
    address[] public commissioners; 

    event DepositPay(uint amount, address commissioner, uint when);
    event GetPaid(uint amount, address commissioner, uint when);

    constructor(uint _payPeriod) payable {
        require(
            _payPeriod > 1,
            "Pay period cannot be too small "
        );
        payPeriod = _payPeriod * 1 days;
        owner = payable(msg.sender);
    }

    receive() external payable {
        totalAmount += msg.value; 
    }

    function depositPay(uint _amount, uint _interval) external payable {
        require(_amount > 0, "Payment has to be greater than 0!"); 
        require(msg.sender.balance > _amount, "You don't have enough ETH to pay");

        payable(this).transfer(_amount); 
        emit DepositPay(_amount, msg.sender, block.timestamp);

        latestTime[msg.sender] = block.timestamp;
        eachPayAmount[msg.sender] = _amount / _interval; 
        paymentCount[msg.sender] = _interval; 
    }

    function getPaid() public {
        require(msg.sender == owner, "You are not the owner of the smart contract!");
        for(uint i = 0; i <= commissioners.length; i++){
            address commissioner = commissioners[i]; 
            if (paymentCount[commissioner] > 0) {
                if (block.timestamp >= payPeriod + latestTime[commissioner]) {
                    latestTime[commissioner] = block.timestamp; // update last payment time
                    paymentCount[msg.sender] -= 1; 
                    owner.transfer(eachPayAmount[commissioner]); 
                    emit GetPaid(address(this).balance, commissioner, block.timestamp);
                }
            }
        }
    }

    // debug purpose ONLY  
    function _withdraw() public { // debugging purpose only 
        require(msg.sender == owner, "You are not the owner of the smart contract!");
        owner.transfer(address(this).balance);
    }
}
