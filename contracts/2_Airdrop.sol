// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./1_Token.sol";

contract Airdrop  {

    // Using Libs

    // Structs
    struct Subscriber {
        uint256 amountReceived;
        bool isRegistered;
    }

    // Enum
    enum Status { ACTIVE, PAUSED, CANCELLED } // mesmo que uint8


    // Properties
    address private owner;
    address public tokenAddress;
    address[] private subscribers;
    Status contractState;
    uint256 private balance;

    mapping(address => Subscriber) private addressToSubscriber;

    // Modifiers
    modifier isOwner() {
        require(msg.sender == owner , "Sender is not owner!");
        _;
    }

    // Events
    event NewSubscriber(address beneficiary, uint amount);

    // Constructor
    constructor(address token) {
        owner = msg.sender;
        tokenAddress = token;
        contractState = Status.ACTIVE;
        balance = CryptoToken(tokenAddress).balanceOf(address(this));
        // requestBalance();
    }


    // Public Functions
    function getBalance() public view returns (uint256) {
        return CryptoToken(tokenAddress).balanceOf(address(this));
    }

    function getAmountReceived() public view returns (uint256) {
        return (addressToSubscriber[msg.sender].amountReceived);
    }

    function getState() public view returns(Status) {
        return contractState;
    }

    function subscribe() public returns(address) {
        require(hasSubscribed(msg.sender) == false, "Address already registered");
        require(contractState == Status.ACTIVE, "Contract not activate.");
        addressToSubscriber[msg.sender] = Subscriber(0,true);
        subscribers.push(msg.sender);
        return msg.sender;
    }

    function execute() public isOwner returns(bool) {
        require(contractState == Status.ACTIVE, "Contract not activate.");
        uint256 amountToTransfer = balance / subscribers.length;
        for (uint i = 0; i < subscribers.length; i++) {
            require(subscribers[i] != address(0));
            require(CryptoToken(tokenAddress).transfer(subscribers[i], amountToTransfer));
            addressToSubscriber[subscribers[i]].amountReceived += CryptoToken(tokenAddress).balanceOf(subscribers[i]);
        }
        return true;
    }

    function changeStatus(uint256 status) public isOwner {
        // ACTIVE = 0, PAUSED = 1, CANCELLED = 2
        if(status == 0){
            contractState = Status.ACTIVE;
        } else if (status == 1){
            contractState = Status.PAUSED;
        } else if (status == 2){
            contractState = Status.CANCELLED;
        }
    }

    function hasSubscribed(address subscriber) public view returns(bool) {
        if(addressToSubscriber[subscriber].isRegistered){
            return true;
        }
        return false;
    }

    // Private Functions
    //Criar função para receber 50% dos fundos na criação do airdrop
    // function requestBalance() public isOwner {
    //     uint256 value = CryptoToken(tokenAddress).totalSupply() * 5/10;
    //     require(CryptoToken(tokenAddress).transferFrom(tokenAddress, address(this), value));
    //     balance = value;            
    // }

    // Kill
    function kill(address redeem) public isOwner {
        require(contractState == Status.CANCELLED, "Contract not cancelled.");
        require(CryptoToken(tokenAddress).transfer(redeem, balance), "Funds transferred and contract destroyed");
        selfdestruct(payable(owner));
    }   
}