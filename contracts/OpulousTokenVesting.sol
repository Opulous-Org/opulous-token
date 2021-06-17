// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "./OwnerOperator.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OpulousTokenVesting is OwnerOperator {
    IERC20 token;

    struct Lockbox {
        address beneficiary;
        uint balance;
        uint releaseTime; // seconds since epoch
    }

    // Numbered lockboxes support possibility of multiple tranches per address
    Lockbox[] public lockboxes;

    event LockboxDeposit(address sender, uint amount, uint releaseTime);   
    event LockboxWithdrawal(address receiver, uint amount);

    constructor(address tokenContract) OwnerOperator( msg.sender ) {
        token = IERC20(tokenContract);
    }

    // Support deposits after vesting contract creation
    function deposit(address beneficiary, uint amount, uint releaseTime) public 
    {
        require(token.transferFrom(msg.sender, address(this), amount));
        emit LockboxDeposit(msg.sender, amount, releaseTime);
        lockboxes.push( Lockbox( beneficiary, amount, releaseTime ) ); 
    }

    /** @dev Allow beneficiary or contract operator to transfer tokens to beneficiary. */ 
    function withdraw(uint lockboxId) public
    {
        Lockbox storage lb = lockboxes[lockboxId];
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

    function countBeneficiaryLockboxes( address beneficiary )
        view public
        returns( uint256 count )
    {
        uint256 total = 0;
        for( uint256 id = 0; id < lockboxes.length; id++ )
            if( lockboxes[id].beneficiary == beneficiary )
                total++;

        return (total);
    }

    function findBeneficiaryLockboxIds( address beneficiary )
        view public
        returns( uint256[] memory index )
    {
        uint256 count = countBeneficiaryLockboxes( beneficiary );
        if( count == 0 )
            return( new uint256[](0) );
        
        uint256[] memory result = new uint256[]( count );
        for( uint256 id = 0; id < lockboxes.length; id++ )
            if( lockboxes[id].beneficiary == beneficiary )
                result[ --count ] = id;

        return( result );
    }

    function totalVesting()
        view public
        returns(uint256 total)
    {
        uint256 sum = 0;
        for( uint256 i = 0; i < lockboxes.length; i++ )
            sum += lockboxes[i].balance;

        return (sum);
    }
}
