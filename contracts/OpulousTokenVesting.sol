// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "./OwnerOperator.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OpulousTokenVesting is OwnerOperator {
    IERC20 public token;

    struct Lockbox {
        address beneficiary;
        uint balance;
        uint releaseTime; // seconds since epoch
    }

    // Numbered lockboxes support possibility of multiple tranches per address
    Lockbox[] public lockboxes;

    // Cache the lockbox ids for each benficiary to reduce gas
    mapping(address => uint[]) public beneficiaryLockboxIdMap;

    event LockboxDeposit(address beneficiary, uint amount, uint releaseTime);   
    event LockboxWithdrawal(address receiver, uint amount);

    constructor(address tokenContract) OwnerOperator( msg.sender ) {
        token = IERC20(tokenContract);
    }

    // Support deposits after vesting contract creation
    function deposit(address beneficiary, uint amount, uint releaseTime) public 
    {
        require(beneficiary != address(0), "Beneficiary is the zero address");
        require(amount > 0, "Amount must be larger than zero");
        require(releaseTime > block.timestamp, "Release time must be in the future");

        lockboxes.push( Lockbox( beneficiary, amount, releaseTime ) );
        beneficiaryLockboxIdMap[ beneficiary ].push( lockboxes.length - 1 );

        require(token.transferFrom(msg.sender, address(this), amount));
        emit LockboxDeposit(beneficiary, amount, releaseTime);
    }

    /** @dev Allow beneficiary or contract operator to transfer tokens to beneficiary. */ 
    function withdraw(uint lockboxId) public
    {
        Lockbox storage lb = lockboxes[lockboxId];
        require(lb.releaseTime > 0, "Lockbox does not exist");
        require(lb.balance > 0, "Lockbox has no balance remaining");
        require(
            lb.beneficiary == msg.sender 
            || operator() == msg.sender, "Cannot withdraw for another account" );
        require(lb.releaseTime <= block.timestamp, "Tokens have not been released yet" );
        uint amount = lb.balance;
        lb.balance = 0;
        emit LockboxWithdrawal(lb.beneficiary, amount);
        require(token.transfer(lb.beneficiary, amount));
    }

    //
    // Read only
    //

    function lockbox( uint256 lockboxId )
        view public
        returns( address beneficiary, uint256 balance, uint256 releaseTime )
    {
        Lockbox storage lb = lockboxes[ lockboxId ];
        return( lb.beneficiary, lb.balance, lb.releaseTime );   
    }

    function beneficiaryLockboxIds( address beneficiary )
        view public
        returns( uint length, uint256[] memory lockboxIds )
    {
        lockboxIds = beneficiaryLockboxIdMap[ beneficiary ];
        return( lockboxIds.length, lockboxIds );
    }

    function currentBalance()
        view public
        returns(uint256 total)
    {
        uint256 sum = 0;
        for( uint256 i = 0; i < lockboxes.length; i++ )
            sum += lockboxes[i].balance;

        return (sum);
    }
}
