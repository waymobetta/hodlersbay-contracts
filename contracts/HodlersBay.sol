pragma solidity ^0.4.15;

contract HodlersBay {
    // STATE VARIABLES
    address public owner;
    
    // MAPPINGS
    mapping(address => uint256) public accountBalance;
    mapping(address => uint256) timelocks;
    
    // MODIFIERS
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    // EVENTS
    event _Storeth(address indexed _from, uint256 _value, uint256 _timestamp);
    event _Withdraweth(address indexed _from, uint256 _value, uint256 _timestamp);
    
    // CONSTRUCTOR
    function HodlersBay() {
        owner = msg.sender;
    }
    
    // SETTERS
    function store(uint256 _secsAfter) external payable {
        // require address sending to have greater than 0 ether
        require(msg.sender.balance > 0);
        // send ether from sending account to contract
        uint256 storedAmount = msg.value;
        // add store amount to addressBalance mapping
        accountBalance[msg.sender] += storedAmount;
        // set timelock
        setTimelock(_secsAfter);
        // fire store event 
        _Storeth(msg.sender, storedAmount, block.timestamp);
    }
    
    function withdraw(uint256 _amountRequested) external {
        require(isTimeUp());
        // multiply _amountRequested amount (ether) by wei conversion (1 ether) to obtain wei value
        uint256 amount = _amountRequested * 1000000000000000000;
        // require address requesting funds to have had a HodlersBay balance greater than 0 ether
        require(accountBalance[msg.sender] > 0);
        // require address requesting funds to have a HodlersBay balance greater than amount requested 
        require(amount <= accountBalance[msg.sender]);
        // return entire account balance to the caller
        msg.sender.transfer(amount);
        // set account balance to 0
        accountBalance[msg.sender] -= amount;
        // fire withdraw event
        _Withdraweth(msg.sender, amount, block.timestamp);
    }
    
    function setTimelock(uint256 _secsAfter) internal returns (uint256) {
        timelocks[msg.sender] = now + _secsAfter * 1 seconds;
    }
    
    // GETTERS
    function HodlersBayBalance(address _addr) public returns (uint256) {
        return accountBalance[_addr];
    }
    
    function getTimelock() public returns (uint256, bool) {
        if (timelocks[msg.sender] > 0) {
            return (timelocks[msg.sender], true);
        }
        return (timelocks[msg.sender], false);
    }
    
    function isTimeUp() public returns (bool) {
        if (now >= timelocks[msg.sender] * 1 seconds) {
            return true;
        }
        return false;
    }

    // KILL
    function kill() onlyOwner public {
        selfdestruct(owner);
    }
}
