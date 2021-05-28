// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OpulousTokenVesting {
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
    event LockboxesInitialized(string group);

    constructor(address tokenContract) {
        token = IERC20(tokenContract);
        initializeLockboxes();
    }

    // Support deposits after vesting contract creation
    function deposit(address beneficiary, uint amount, uint releaseTime) public returns(bool success) {
        require(token.transferFrom(msg.sender, address(this), amount));
        emit LockboxDeposit(msg.sender, amount, releaseTime);
        lockboxes.push( Lockbox( msg.sender, amount, releaseTime ) ); 
        return true;
    }

    /*
    function findByBeneficiary( address beneficiary ) view public returns(uint256[] index,{



    }*/

    function remainingBalance() view public returns(uint256) {
        return (100);
    }

    function withdraw(uint lockboxNumber) public returns(bool success) {
        Lockbox storage lb = lockboxes[lockboxNumber];
        require(lb.beneficiary == msg.sender);
        require(lb.releaseTime <= block.timestamp);
        uint amount = lb.balance;
        lb.balance = 0;
        emit LockboxWithdrawal(msg.sender, amount);
        require(token.transfer(msg.sender, amount));

        return true;
    }

    bool r1aInitialized = false;
    bool r1bInitialized = false;

    /* 
        We break the large number of lockboxes down into groups so we don't run out of gas.
        this can be called repeatedly, and each time it creates another group
        of lockboxes until all are initialized.
    */

    function initializeLockboxes() public {

        // Use https://www.epochconverter.com/ to create release times, in seconds since epoch
        // deposit( Ethereum wallet address, OPUL tokens, time of release in seconds since epoch ); 

        uint ONE_MONTH = 2592000; // in seconds
        uint TGE = 1635711346; // in seconds GMT Sunday, October 31, 2021 8:15:46 PM 
        if( r1aInitialized == false ) {
            r1allocations( TGE, 1e16 );
            r1allocations( TGE + 4 * ONE_MONTH, 1e16 * 2 );
            r1allocations( TGE + 8 * ONE_MONTH, 1e16 );
            r1allocations( TGE + 10 * ONE_MONTH, 1e16 );
            r1allocations( TGE + 12 * ONE_MONTH, 1e16 );

            r1aInitialized = true;
            emit LockboxesInitialized('r1a');
            return;
        }
        
        if( r1bInitialized == false ) {
            r1allocations( TGE + 14 * ONE_MONTH, 1e16 );
            r1allocations( TGE + 16 * ONE_MONTH, 1e16 );
            r1allocations( TGE + 18 * ONE_MONTH, 1e16 );
            r1allocations( TGE + 20 * ONE_MONTH, 1e16 );

            r1bInitialized = true;
            emit LockboxesInitialized('r1b');
            return;
        }
    }

    // token amount are in hundredths, so multiply by 1e16 to get token amount (instead of 1e18)
    function r1allocations( uint releaseTime, uint multiplier ) private {
        // Ditto
        lockboxes.push( Lockbox( address(0x32827126bD03bCFcD39aB6206FD73dE95608D8e9), 1666667  * multiplier, releaseTime ) ); // Wilcox
        lockboxes.push( Lockbox( address(0xda3F5F2E59188a29F2107A370Bf059Aea2F747d0), 2500000  * multiplier, releaseTime ) ); // Houston
        lockboxes.push( Lockbox( address(0xD945B8a2BDdA70b0682E389e35fa707482F44D89), 1666667  * multiplier, releaseTime ) ); // Mawdsley
        lockboxes.push( Lockbox( address(0x03d1565F246B86fE83631bec956e1166B55c5115), 1666667  * multiplier, releaseTime ) ); // ben ams
        lockboxes.push( Lockbox( address(0x2e60C71D84A4ABCA39d6E616a70df0EaB63d3F39), 1666667  * multiplier, releaseTime ) ); // Zuu
        lockboxes.push( Lockbox( address(0x274039574C0aC5d793E13796dec973AA9F0d2924), 1666667  * multiplier, releaseTime ) ); // Testaseca
        lockboxes.push( Lockbox( address(0x99D6FF42FC7c30961EFd8970EC66fa338F97c029), 1666667  * multiplier, releaseTime ) ); // Hay
        lockboxes.push( Lockbox( address(0x030740C1fb8F4841Ac647E346F299F8DC2c58306), 1666667  * multiplier, releaseTime ) ); // Cartaxo
        lockboxes.push( Lockbox( address(0xA7d53695aF1FD11E0b75d37695290C102D59D743), 1666667  * multiplier, releaseTime ) ); // Beltramini
        lockboxes.push( Lockbox( address(0x977e2e6Af91f1beab0B24Da33B016C578f34491E),  833333  * multiplier, releaseTime ) ); // Lee
        lockboxes.push( Lockbox( address(0x793540Ee8ba4db095838AF0afe2Ac11C1C57616E), 1666667  * multiplier, releaseTime ) ); // Skrovina
        lockboxes.push( Lockbox( address(0x8d846cc35B486968a429c1c0C5FDdA28bD18DABb), 1666667  * multiplier, releaseTime ) ); // Cesar
        lockboxes.push( Lockbox( address(0xbE80C9607B2f88f82A0D4f523FEe4132B0992727), 5000000  * multiplier, releaseTime ) ); // Walsh
        lockboxes.push( Lockbox( address(0x0F72Ee9e72cfCB196B03BF3a63DDAba823915787), 1666667  * multiplier, releaseTime ) ); // Moore 
        lockboxes.push( Lockbox( address(0x5Ac4f64095C62ba2034b61E957C339440a836E36), 1666667  * multiplier, releaseTime ) ); // Mason
        lockboxes.push( Lockbox( address(0xDfE5CAd7e295C34f8354ddFC9660D817D8A2a1Ed), 1666667  * multiplier, releaseTime ) ); // Rodriguez
        lockboxes.push( Lockbox( address(0x60442b45764359BB48864b2cBE0135729E643BA1), 1666667  * multiplier, releaseTime ) ); // Parsons
        lockboxes.push( Lockbox( address(0x964f9ce358C7b08Ae744da0C5a61eB94212fa404), 1666667  * multiplier, releaseTime ) ); // Adex
        lockboxes.push( Lockbox( address(0x9a561Ffa7001F9eCC4F9B3Ffe2b0e6b3038ba98b), 1666667  * multiplier, releaseTime ) ); // Gatfield
        lockboxes.push( Lockbox( address(0x90C611c712548947a1eB8d876C7175B1E07C5358), 1666667  * multiplier, releaseTime ) ); // Clinton
        lockboxes.push( Lockbox( address(0xeD07fa55cac9164DD5d37B8e2EB0f805B81F16A7), 1666667  * multiplier, releaseTime ) ); // Rowe
        lockboxes.push( Lockbox( address(0x6d999e05Ad92FcB23DF28399C19A1D125Bff1417), 1666667  * multiplier, releaseTime ) ); // Ingham
        lockboxes.push( Lockbox( address(0x5E8796d77C1eb28DB20FD75D53c5bC19CE51Eb8c), 1666667  * multiplier, releaseTime ) ); // Napper

        // R1 ONLY
        lockboxes.push( Lockbox( address(0x29f75d9bBFecB1a7C039738518ad64f662d0F289),  50000000 * multiplier, releaseTime ) ); // Uvarov
        lockboxes.push( Lockbox( address(0x460dB0725fA2F22EC02544F3c3d4d74bF7B52FfC),  33333333 * multiplier, releaseTime ) ); // Velmeshev
        lockboxes.push( Lockbox( address(0x8faC6208587dD6c2c7f0b68f00A379e5fc842822), 416666667 * multiplier, releaseTime ) ); // Peak
        lockboxes.push( Lockbox( address(0x84eb534e0B24962302764514930434E01d5ff25a),  66666667 * multiplier, releaseTime ) ); // Hammond
        lockboxes.push( Lockbox( address(0xa2e3BdaE9569c89B13cD4407a87FD063253b84F8), 166666667 * multiplier, releaseTime ) ); // Capital

        // R1 Mixed Round
        lockboxes.push( Lockbox( address(0x8e5CfA612cc68087a36b8AA549DE6b86c1657d69),  83333333 * multiplier, releaseTime ) ); // Nazaryan
        lockboxes.push( Lockbox( address(0x76c08B0bF53168baA2008bf51830BC94c1FEf454),  66666667 * multiplier, releaseTime ) ); // Ellio
        lockboxes.push( Lockbox( address(0x4fdc7161019BC798dCa67B9E460623f81bdD9f90),  83333333 * multiplier, releaseTime ) ); // Independent
        lockboxes.push( Lockbox( address(0x4C84181233Fa9a747BcA81Da9903Cec6999eB89f),  83333333 * multiplier, releaseTime ) ); // Winder
        lockboxes.push( Lockbox( address(0xD3388E1ed707443442Afa9Bb133D9dfFacD9b467), 200000000 * multiplier, releaseTime ) ); // Walker
        lockboxes.push( Lockbox( address(0x094CE14360Ac5D07ef031C5DfA290dE3B076641a), 125000000 * multiplier, releaseTime ) ); // NGC
        lockboxes.push( Lockbox( address(0xDe545722c14EA858A6BDB9Ad5B7dd83cA2F703c8), 125000000 * multiplier, releaseTime ) ); // Lau
        lockboxes.push( Lockbox( address(0x0DC874Fb5260Bd8749e6e98fd95d161b7605774D), 208333333 * multiplier, releaseTime ) ); // Group
        lockboxes.push( Lockbox( address(0x6483daf6272C699B150F19113E8fFf9aCb2b00E3),  83333333 * multiplier, releaseTime ) ); // Yue
    }

    function r2allocations( uint releaseTime, uint multiplier ) private {
        // Only
        //lockboxes.push( Lockbox( address(0x32827126bD03bCFcD39aB6206FD73dE95608D8e9), 1666667  * multiplier, releaseTime ) ); // Wilcox
    }
}
