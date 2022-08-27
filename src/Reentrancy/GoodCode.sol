pragma solidity ^0.8.16;

/** 
 * @title GoodCode
 * @dev Implements the best practice to prevent reentrancy vulnerability 
 */
contract GoodCode {
    bool internal lock; // mutex for reentrancy
    mapping (address=>uint) public Balances; // store user balance in the vault

    // modifier to check the mutex 
    modifier isLocked() {
        require(!lock, "Locked, cannot re-enter");
        _;
    }

    /** 
     * @dev Add the ethers to Balances.
     */
    function deposit() external payable {
        Balances[msg.sender] += msg.value;
    }

    /** 
     * @dev Send all the user balance using transfer() function.  
     */
    function withdraw() external isLocked {
        lock = true; // lock mutex
        uint256 balance = Balances[msg.sender];
        require(balance > 0, "Zero balance");
        // change state variables before transfering
        Balances[msg.sender] = 0; 
        // send() and transfer() are safe against reentrancy
        bool success = payable(msg.sender).send(balance);
        require(success, "Failed to send Ether");     
        lock = false; 
    }

    /** 
     * @dev a view function to get total balance stored in this contract's address 
     * @return address(this).balance 
     */    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}