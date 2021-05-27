// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OpulousTokenVesting {
    IERC20 token;

    struct LockBoxStruct {
        address beneficiary;
        uint balance;
        uint releaseTime;
    }

    // Numbered lockBoxes support possibility of multiple tranches per address
    LockBoxStruct[] public lockBoxStructs; 

    event LogLockBoxDeposit(address sender, uint amount, uint releaseTime);   
    event LogLockBoxWithdrawal(address receiver, uint amount);

    constructor(address tokenContract) {
        token = IERC20(tokenContract);
    }

    function deposit(address beneficiary, uint amount, uint releaseTime) public returns(bool success) {
        require(token.transferFrom(msg.sender, address(this), amount));
        LockBoxStruct memory l;
        l.beneficiary = beneficiary;
        l.balance = amount;
        l.releaseTime = releaseTime;
        lockBoxStructs.push(l);
        emit LogLockBoxDeposit(msg.sender, amount, releaseTime);
        return true;
    }

    function withdraw(uint lockBoxNumber) public returns(bool success) {
        LockBoxStruct storage l = lockBoxStructs[lockBoxNumber];
        require(l.beneficiary == msg.sender);
        require(l.releaseTime <= block.timestamp);
        uint amount = l.balance;
        l.balance = 0;
        emit LogLockBoxWithdrawal(msg.sender, amount);
        require(token.transfer(msg.sender, amount));
        return true;
    }    
}
