pragma solidity ^0.8.16;

/** 
 * @title BadCode
 * @dev Implements a simple reentrancy vulnerability 
 */
contract BadCode {
    mapping (address=>uint) public Balances; // store user balance in the vault

    /** 
     * @dev Add the ethers to Balances.
     */
    function deposit() external payable {
        Balances[msg.sender] += msg.value;
    }

    /** 
     * @dev Send all the user balance using call() function. This is a bad practice. 
     */
    function withdraw() external {
        require(Balances[msg.sender] > 0);
        (bool success, ) = msg.sender.call{value: Balances[msg.sender]}("");
        require(success, "Failed to send Ether");
        Balances[msg.sender] = 0; 
    }

    /** 
     * @dev a view function to get total balance stored in this contract's address 
     * @return address(this).balance 
     */    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}