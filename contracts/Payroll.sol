pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 is Ownable {
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external; 

    function transfer(address to, uint256 value) external returns (bool);
}

contract Payroll {
    uint public payPeriod;
    address payable public owner;
    uint public totalAmount; 
    mapping(address => uint) public latestTime; 
    mapping(address => uint) public eachPayAmount;
    mapping(address => uint) public paymentCount;
    address[] public commissioners; 

    IERC20 USDC       = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 WETH       = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 DAI        = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    event DepositPay(uint amount, uint when);
    event GetPaid(uint amount, uint when);

    constructor(uint _payPeriod) payable {
        require(
            _payPeriod > 1,
            "Pay period cannot be too small "
        );
        payPeriod = _payPeriod;
        owner = payable(msg.sender);
    }

    receive() external payable {
        totalAmount += msg.value; 
    }

    function depositPay(uint _amount, uint _interval) external payable {
        require(_amount > 0, "Payment has to be greater than 0!"); 
        require(msg.sender != owner, "You are paying yourself!");

        USDC.approve(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa,  _amount);
        USDC.transferFrom(msg.sender, address(this), _amount);
        // require(success, "Payment deposit failed!");

        latestTime[msg.sender] = now;
        eachPayAmount[msg.sender] = _amount / _interval; 
        paymentCount[msg.sender] = _interval; 

    }

    function getPaid() public {
        for(uint i = 0; i <= commissioners.length; i++){
            address commissioner = commissioners[i]; 
            if (paymentCount[commissioner] > 0) {
                if (now >= payPeriod + latestTime[commissioner]) {
                    owner.transfer(address(this).balance); 
                    latestTime[commissioner] = now; // update last payment time
                    emit GetPaid(address(this).balance, block.timestamp);
                }
            }
        }
    }
}
