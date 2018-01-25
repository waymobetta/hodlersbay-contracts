pragma solidity ^0.4.15;

contract HodlersBay {
    // STATE VARIABLES
    address public owner;
    uint256 public whateversLeft;
    uint256 public maroonerTax = 1000;
    uint256 public shareOfTheRiches;
    
    // whitelisted addresses
    address[] public hodlers;
    
    // MAPPINGS
    mapping (address => bool) public hasBlackSpot;
    mapping (address => uint256) public accountBalance;
    mapping (address => uint256) timelocks;
    
    // MODIFIERS
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    // EVENTS
    event _welcomeAboard(address indexed _addr, uint256 _value, uint256 _timestamp);
    event _maroon(address indexed _addr, uint256 _value, uint256 _timestamp);
    event _walkThePlank(address indexed _addr, uint256 _value, uint256 _timestamp);
    
    // CONSTRUCTOR
    function HodlersBay() {
        owner = msg.sender;
        hodlers.push(msg.sender);
    }
    
    // SETTERS
    function store(uint256 _secsAfter) public payable {
        // require address is not blacklisted from hodlers' bay
        require(!hasBlackSpot[msg.sender]);
        // require address sending to have greater than 0 ether
        require(msg.sender.balance > 0);
        // send ether from sending account to contract
        uint256 storedAmount = msg.value;
        // add store amount to addressBalance mapping
        accountBalance[msg.sender] += storedAmount;
        // add to whitelist
        hodlers.push(msg.sender);
        // set timelock
        setTimelock(_secsAfter);
        // fire store event 
        _welcomeAboard(msg.sender, storedAmount, block.timestamp);
    }
    
    
    function withdraw(uint256 _amountRequested) public returns (uint256) {
        require(isTimeUp());
        // multiply _amountRequested amount (ether) by wei conversion (1 ether) to obtain wei value
        uint256 amount = _amountRequested * 1000000000000000000;
        // require address requesting funds to have had a hodl balance greater than 0 ether
        require(accountBalance[msg.sender] > 0);
        // take marooner's tax
        whateversLeft = deathAndTaxes(amount);
        // award Black Spot to address
        hasBlackSpot[msg.sender] = true;
        // fire black spot event => walk the plank
        _walkThePlank(msg.sender, maroonerTax, block.timestamp);
        // require address requesting funds to have a hodl balance greater than amount requested 
        require(whateversLeft <= accountBalance[msg.sender]);
        // return whateversLeft to the caller
        msg.sender.transfer(whateversLeft);
        // subtract amount request (after deathAndTaxes) from account balance 
        accountBalance[msg.sender] -= whateversLeft;
        // fire withdraw event
        _maroon(msg.sender, whateversLeft, block.timestamp);
        // distribute marooner's tax amongst other hodlers in the bay
        distributeLoot();
        return whateversLeft;
    }
    
    // TODO: remove marooner from hodlers whitelist
    // function removeFromHodlers() {
    // }
    
    function setTimelock(uint256 _secsAfter) internal returns (uint256) {
        timelocks[msg.sender] = now + _secsAfter * 1 seconds;
    }
    
    // TODO: disperse loot to other addresses in whitelist
    function distributeLoot() internal returns (uint256) {
        shareOfTheRiches = maroonerTax / hodlers.length;
        return shareOfTheRiches;
    }
    
    function deathAndTaxes(uint256 _amount) internal returns (uint256) {
        uint256 loot = _amount - maroonerTax;
        return loot;
    }
    
    // GETTERS
    function getHodlers() public returns (address[]) {
        return hodlers;
    }
    
    function hodlersCount() public returns (uint256) {
        return hodlers.length;
    }
    
    function hodlersBayBalance(address _addr) public returns (uint256) {
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
    function kill() public onlyOwner {
        selfdestruct(owner);
    }
}
