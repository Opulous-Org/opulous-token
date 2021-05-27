// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OpulousTokenVesting {
    IERC20 token;

    struct LockBox {
        address beneficiary;
        uint balance;
        uint releaseTime; // seconds since epoch
    }

    // Numbered lockBoxes support possibility of multiple tranches per address
    LockBox[] public lockBoxes; 

    event LockBoxDeposit(address sender, uint amount, uint releaseTime);   
    event LockBoxWithdrawal(address receiver, uint amount);

    constructor(address tokenContract) {
        token = IERC20(tokenContract);
        initializeLockBoxes();
    }

    function deposit(address beneficiary, uint amount, uint releaseTime) public returns(bool success) {
        require(token.transferFrom(msg.sender, address(this), amount));
        LockBox memory lb;
        lb.beneficiary = beneficiary;
        lb.balance = amount;
        lb.releaseTime = releaseTime;
        lockBoxes.push(lb);
        emit LockBoxDeposit(msg.sender, amount, releaseTime);

        return true;
    }

    function withdraw(uint lockBoxNumber) public returns(bool success) {
        LockBox storage lb = lockBoxes[lockBoxNumber];
        require(lb.beneficiary == msg.sender);
        require(lb.releaseTime <= block.timestamp);
        uint amount = lb.balance;
        lb.balance = 0;
        emit LockBoxWithdrawal(msg.sender, amount);
        require(token.transfer(msg.sender, amount));

        return true;
    }

    function initializeLockBoxes() private {
        // Use https://www.epochconverter.com/ to create release times, in seconds since epoch
        // LockBox( Ethereum wallet address, OPUL tokens, time of release in seconds since epoch)

        // 1635711346 = GMT Sunday, October 31, 2021 8:15:46 PM 
        lockBoxes.push( LockBox( address(0x07865c6e87b9f70255377e024ace6630c1eaa37f), 1       * 1e18, 1635711346 ) );
        lockBoxes.push( LockBox( address(0x07865c6e87b9f70255377e024ace6630c1eaa37f), 1000    * 1e18, 1635711346 ) );
        lockBoxes.push( LockBox( address(0x07865c6e87b9f70255377e024ace6630c1eaa37f), 1000000 * 1e18, 1635711346 ) );
    }   
}
