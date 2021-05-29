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
    event LockboxesInitialized( string group, uint256 total );

    constructor(address tokenContract) {
        token = IERC20(tokenContract);
        //initializeLockboxes();  // first batch
    }

    // Support deposits after vesting contract creation
    function deposit(address beneficiary, uint amount, uint releaseTime) public returns(bool success) {
        require(token.transferFrom(msg.sender, address(this), amount));
        emit LockboxDeposit(msg.sender, amount, releaseTime);
        lockboxes.push( Lockbox( beneficiary, amount, releaseTime ) ); 
        return true;
    }

    function withdraw(uint lockboxId) public returns(bool success) {
        Lockbox storage lb = lockboxes[lockboxId];
        require(lb.beneficiary == msg.sender, "Cannot withdraw for another account" );
        require(lb.releaseTime <= block.timestamp, "Tokens have not been released yet" );
        uint amount = lb.balance;
        lb.balance = 0;
        emit LockboxWithdrawal(msg.sender, amount);
        require(token.transfer(msg.sender, amount));

        return true;
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
        uint256 i;
        for( i = 0; i < lockboxes.length; i++ )
            sum += lockboxes[i].balance;

        return (sum);
    }

    //
    // Initialization of lockboxes, grouped so they can be done
    // in multiple batches to deal with gas limitations
    // initializeLockboxes() can be called by anyone
    //

    bool r1aInitialized = false;
    bool r1bInitialized = false;
    bool r2aInitialized = false;
    bool r2bInitialized = false;
    bool kolInitialized = false;
    bool kol2Initialized = false;
    bool kol3Initialized = false;
    bool seedInitialized = false;

    /* 
        We break the large number of lockboxes down into batches so we don't run out of gas.
        This function can be called repeatedly and by anyone, and each time it creates another set
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

            r1aInitialized = true;
            emit LockboxesInitialized( 'r1a', lockboxes.length );
            return;
        }

        if( r1bInitialized == false ) {

            r1allocations( TGE + 12 * ONE_MONTH, 1e16 );
            r1allocations( TGE + 14 * ONE_MONTH, 1e16 );
            r1allocations( TGE + 16 * ONE_MONTH, 1e16 );
            r1allocations( TGE + 18 * ONE_MONTH, 1e16 );
            r1allocations( TGE + 20 * ONE_MONTH, 1e16 );

            r1bInitialized = true;
            emit LockboxesInitialized('r1b', lockboxes.length);
            return;
        }

        if( r2aInitialized == false ) {

            // R2 community at TGE
            lockboxes.push( Lockbox( address(0xe6a1Fd40E94F258eA86F521c2cf83cd1e91230bD), 9866667 * 1e16, TGE ) ); // Cezar

            r2allocations( TGE );
            r2allocations( TGE + 3 * ONE_MONTH );
            r2allocations( TGE + 6 * ONE_MONTH );
            r2allocations( TGE + 8 * ONE_MONTH );
            r2allocations( TGE + 10 * ONE_MONTH );

            r2aInitialized = true;
            emit LockboxesInitialized('r2a', lockboxes.length);
            return;
        }

        if( r2bInitialized == false ) {
            r2allocations( TGE + 12 * ONE_MONTH );
            r2allocations( TGE + 14 * ONE_MONTH );
            r2allocations( TGE + 16 * ONE_MONTH );
            r2allocations( TGE + 18 * ONE_MONTH );
            r2allocations( TGE + 20 * ONE_MONTH );

            r2bInitialized = true;
            emit LockboxesInitialized('r2b', lockboxes.length);
            return;
        }

        if( kolInitialized == false ) {
            // OLD KOL Terms
            kolAllocations( TGE,                  15 * 1e14 );
            kolAllocations( TGE + 3 * ONE_MONTH,  25 * 1e14 );
            kolAllocations( TGE + 6 * ONE_MONTH,  30 * 1e14 );
            kolAllocations( TGE + 12 * ONE_MONTH, 30 * 1e14 );

            // KOL one year terms
            lockboxes.push( Lockbox( address(0x58a3e0697f931B7958DefeA1d123cd1080ad938d), 17647059 * 10 * 1e14, TGE ) );
            lockboxes.push( Lockbox( address(0x58a3e0697f931B7958DefeA1d123cd1080ad938d), 17647059 * 15 * 1e14, TGE + 3 * ONE_MONTH ) );
            lockboxes.push( Lockbox( address(0x58a3e0697f931B7958DefeA1d123cd1080ad938d), 17647059 * 20 * 1e14, TGE + 6 * ONE_MONTH ) );
            lockboxes.push( Lockbox( address(0x58a3e0697f931B7958DefeA1d123cd1080ad938d), 17647059 * 25 * 1e14, TGE + 9 * ONE_MONTH ) );
            lockboxes.push( Lockbox( address(0x58a3e0697f931B7958DefeA1d123cd1080ad938d), 17647059 * 30 * 1e14, TGE + 12 * ONE_MONTH ) );

            kolInitialized = true;
            emit LockboxesInitialized('kol', lockboxes.length);
            return;
        }

        if( kol2Initialized == false ) {
            // KOL two year terms
            kol2Allocations( TGE,                  10 * 1e14 );
            kol2Allocations( TGE + 3 * ONE_MONTH,  15 * 1e14 );
            kol2Allocations( TGE + 6 * ONE_MONTH,  20 * 1e14 );
            kol2Allocations( TGE + 12 * ONE_MONTH, 25 * 1e14 );
            kol2Allocations( TGE + 24 * ONE_MONTH, 30 * 1e14 );

            // KOL 1_special SAFTS
            lockboxes.push( Lockbox( address(0xDfE5CAd7e295C34f8354ddFC9660D817D8A2a1Ed), 5000000 * 20 * 1e14, TGE ) );
            lockboxes.push( Lockbox( address(0xDfE5CAd7e295C34f8354ddFC9660D817D8A2a1Ed), 5000000 * 20 * 1e14, TGE + 3 * ONE_MONTH ) );
            lockboxes.push( Lockbox( address(0xDfE5CAd7e295C34f8354ddFC9660D817D8A2a1Ed), 5000000 * 20 * 1e14, TGE + 6 * ONE_MONTH ) );
            lockboxes.push( Lockbox( address(0xDfE5CAd7e295C34f8354ddFC9660D817D8A2a1Ed), 5000000 * 10 * 1e14, TGE + 9 * ONE_MONTH ) );
            lockboxes.push( Lockbox( address(0xDfE5CAd7e295C34f8354ddFC9660D817D8A2a1Ed), 5000000 * 10 * 1e14, TGE + 12 * ONE_MONTH ) );
            lockboxes.push( Lockbox( address(0xDfE5CAd7e295C34f8354ddFC9660D817D8A2a1Ed), 5000000 * 10 * 1e14, TGE + 15 * ONE_MONTH ) );
            lockboxes.push( Lockbox( address(0xDfE5CAd7e295C34f8354ddFC9660D817D8A2a1Ed), 5000000 * 10 * 1e14, TGE + 18 * ONE_MONTH ) );

            // KOL 2_special SAFTS
            lockboxes.push( Lockbox( address(0xD5237A08BE8a9133D446F204fDB056F808862450), 2941176 * 20 * 1e14, TGE ) );
            lockboxes.push( Lockbox( address(0xD5237A08BE8a9133D446F204fDB056F808862450), 2941176 * 20 * 1e14, TGE + 6 * ONE_MONTH ) );
            lockboxes.push( Lockbox( address(0xD5237A08BE8a9133D446F204fDB056F808862450), 2941176 * 20 * 1e14, TGE + 12 * ONE_MONTH ) );
            lockboxes.push( Lockbox( address(0xD5237A08BE8a9133D446F204fDB056F808862450), 2941176 * 20 * 1e14, TGE + 15 * ONE_MONTH ) );
            lockboxes.push( Lockbox( address(0xD5237A08BE8a9133D446F204fDB056F808862450), 2941176 * 20 * 1e14, TGE + 18 * ONE_MONTH ) );
            // ===> MISSING Matthew Greer Wallet!!

            kol2Initialized = true;
            emit LockboxesInitialized('kol2', lockboxes.length);
            return;
        }

        if( kol3Initialized == false ) {
            // Current KOL Terms
            kol3Allocations( TGE,                  20 * 1e14 );
            kol3Allocations( TGE + 3 * ONE_MONTH,  20 * 1e14 );
            kol3Allocations( TGE + 6 * ONE_MONTH,  20 * 1e14 );
            kol3Allocations( TGE + 9 * ONE_MONTH,  10 * 1e14 );
            kol3Allocations( TGE + 12 * ONE_MONTH, 10 * 1e14 );
            kol3Allocations( TGE + 15 * ONE_MONTH, 10 * 1e14 );
            kol3Allocations( TGE + 18 * ONE_MONTH, 10 * 1e14 );

            kol3Initialized = true;
            emit LockboxesInitialized('kol3', lockboxes.length);
            return;
        }

        if( seedInitialized == false ) {
            // Current KOL Terms
            seedAllocations( TGE + 4 * ONE_MONTH,  20 * 1e14 );
            seedAllocations( TGE + 9 * ONE_MONTH,  10 * 1e14 );
            seedAllocations( TGE + 12 * ONE_MONTH, 10 * 1e14 );
            seedAllocations( TGE + 15 * ONE_MONTH, 10 * 1e14 );
            seedAllocations( TGE + 18 * ONE_MONTH, 10 * 1e14 );
            seedAllocations( TGE + 21 * ONE_MONTH, 10 * 1e14 );
            seedAllocations( TGE + 24 * ONE_MONTH, 10 * 1e14 );
            seedAllocations( TGE + 27 * ONE_MONTH, 10 * 1e14 );
            seedAllocations( TGE + 30 * ONE_MONTH, 10 * 1e14 );

            seedInitialized = true;
            emit LockboxesInitialized('seed', lockboxes.length);
            return;
        }

        emit LockboxesInitialized('Done!', lockboxes.length);
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

    function r2allocations( uint releaseTime ) private {
        // R2 Only
        lockboxes.push( Lockbox( address(0x0656c424F356E18c1FB72c791040B9AFc882DE15),  4000000 * 1e16, releaseTime ) ); // Nassiri
        lockboxes.push( Lockbox( address(0x87772E10D0A1eeff96a6C566690076C15B32d13B),  5333333 * 1e16, releaseTime ) ); // Kenzi
        lockboxes.push( Lockbox( address(0x44769F146A74Abc66fAA1A16D9C2B5608EDEA627),  8666667 * 1e16, releaseTime ) ); // Coors
        lockboxes.push( Lockbox( address(0xdEE3AC81081eC6318F689df4a35258d046dDd329), 11333333 * 1e16, releaseTime ) ); // Cognitive
        lockboxes.push( Lockbox( address(0xcDB4CC07233A417983D86C68B3bDE0F1f8B4038c),  2666667 * 1e16, releaseTime ) ); // Double Peak
        lockboxes.push( Lockbox( address(0x8b90b067d02132fC7c5cDf64b8cac04D55aBC2B2), 11333333 * 1e16, releaseTime ) ); // Su
        lockboxes.push( Lockbox( address(0x73b0Ada6Fc72521316e97306F059852F808fcF5A), 10000000 * 1e16, releaseTime ) ); // Higgs
        lockboxes.push( Lockbox( address(0x138a822a13Aa403e22c888cD074C10C097305025),  5333333 * 1e16, releaseTime ) ); // Kairon
        lockboxes.push( Lockbox( address(0xCf304823D4d0d8822648A66aDbF67BC57F6dD350),  6666667 * 1e16, releaseTime ) ); // Geelen
        lockboxes.push( Lockbox( address(0x87BAdfCC6b5eb79aCbD108d1208d82dc6A6D48AB),  2666667 * 1e16, releaseTime ) ); // KSI
        lockboxes.push( Lockbox( address(0x9e67D018488aD636B538e4158E9e7577F2ECac12),  3333333 * 1e16, releaseTime ) ); // Beast
        //lockboxes.push( Lockbox( address(0x32), 13333333 * 1e16, releaseTime ) ); // Bi (no address!)
        lockboxes.push( Lockbox( address(0x4e5966ef7edAd28E2026Ce4f52c28458c592933C),   133333 * 1e16, releaseTime ) ); // Hamilton
        //lockboxes.push( Lockbox( address(0xe6a1Fd40E94F258eA86F521c2cf83cd1e91230bD),  * 1e16, releaseTime ) ); // Cezar (no amount!)
        lockboxes.push( Lockbox( address(0xbfDd960844765b1BAC0BF1F01A84Fb1F5aAFe9bC),  6666667 * 1e16, releaseTime ) ); // SubZero
        lockboxes.push( Lockbox( address(0xdb01F2e7d8F0d84771c187C85569363EDb704668),  1333333 * 1e16, releaseTime ) ); // Leow
        lockboxes.push( Lockbox( address(0x34b3aAf611DDB76497dA24f3FC49D233170523D6),  1333333 * 1e16, releaseTime ) ); // Zinur
        //lockboxes.push( Lockbox( address(0x6d798859eccae167e63b42e345d28cbd9ff087f0),   133333 * 1e16, releaseTime ) ); // goodsoilvc

        // R2 from mixed round
        lockboxes.push( Lockbox( address(0xf189A341aCE312e61bebfBb4D20988B863e828A0),  6666667 * 1e16, releaseTime ) ); // Arutyun
        lockboxes.push( Lockbox( address(0xdEAcA9cE26A032b2c1DBCB6cF70ACB1D0c8E4472),  8000000 * 1e16, releaseTime ) ); // Ellio Trades
        lockboxes.push( Lockbox( address(0x6908A427b3F44977bd1c5A36172eD5F390b93A20),  6666667 * 1e16, releaseTime ) ); // Lai indy
        lockboxes.push( Lockbox( address(0x1A68Ac8c05BF8eA142B57486F77005e61d98B443), 13333333 * 1e16, releaseTime ) ); // Winder
        lockboxes.push( Lockbox( address(0x07Ca04Dea1b05ef526F69F82661aa2bc911c7ab2), 20333333 * 1e16, releaseTime ) ); // Walker
        lockboxes.push( Lockbox( address(0xE9902E1f2C6672f7EaFa45C0201450f0A3b9a0Af), 10000000 * 1e16, releaseTime ) ); // NGC
        lockboxes.push( Lockbox( address(0x90Cd453805016A998d420543ac26604718932E15), 27000000 * 1e16, releaseTime ) ); // Lau
        lockboxes.push( Lockbox( address(0x2573010A8183A7E8bB4AD744b44cf6feB3284e8E), 23333333 * 1e16, releaseTime ) ); // Spartan
        lockboxes.push( Lockbox( address(0x6832BeF8DD24c2b0362f62CC49C378ec43a09E60), 15333333 * 1e16, releaseTime ) ); // Cognitive
    }

    function kolAllocations( uint releaseTime, uint multiplier ) private {
        // OLD KOL terms 
        lockboxes.push( Lockbox( address(0x70F6D55E16a3bc1Dd4b5C0f772Cd92A2c75Bee73), 23529412 * multiplier, releaseTime ) ); // EAK
        lockboxes.push( Lockbox( address(0x7dF56E485275570456C26F978434D1E53f04644E), 11764706 * multiplier, releaseTime ) ); // ICONPLUS
        lockboxes.push( Lockbox( address(0x53A2f447C61152917493679F8105811198648d81),  8235294 * multiplier, releaseTime ) ); // Top7
        lockboxes.push( Lockbox( address(0xDF51b930273dD420f617dECe9b79b5c899535765), 11764706 * multiplier, releaseTime ) ); // Kamil
        lockboxes.push( Lockbox( address(0x2D69BAB9738b05048be16DE3E5E0A945b8EeEf3a),  7058824 * multiplier, releaseTime ) ); // Dude
        lockboxes.push( Lockbox( address(0xB6284554b59B8CE4f0529f583Fa571b362731769), 11764706 * multiplier, releaseTime ) ); // ICO Analytics
        lockboxes.push( Lockbox( address(0xdFEE40a82276D9BcFa3c346988cC1E83A664E276),  5882353 * multiplier, releaseTime ) ); // MrBlock
        lockboxes.push( Lockbox( address(0x70031213C95DeECfa44a6C438BcA25134A292eef),  5882353 * multiplier, releaseTime ) ); // CoachK
        lockboxes.push( Lockbox( address(0xb236051287e027a4C5551cbC8300AF222BC7FE53), 17647059 * multiplier, releaseTime ) ); // Ran
        lockboxes.push( Lockbox( address(0xa2a4B7F6a7fDa1Adfd8188373e4484E517138Ae7), 17647059 * multiplier, releaseTime ) ); // Market M
        lockboxes.push( Lockbox( address(0xDb76E50437bAC5d24E26C50B0dffBe2E95716e61), 17647059 * multiplier, releaseTime ) ); // Martini
        lockboxes.push( Lockbox( address(0xce88C6A16494A2838Ad158985c65810c302DcAD6), 17647059 * multiplier, releaseTime ) ); // Hasheur
    }

    // KOL Two year terms
    function kol2Allocations( uint releaseTime, uint multiplier ) private {
        lockboxes.push( Lockbox( address(0x14F61a6d028A26368a4534584BBD648608105bFc),  5882353 * multiplier, releaseTime ) ); // Jesse
        lockboxes.push( Lockbox( address(0x67E309276090BEe7d464dA2c03B750576A4187eE), 11764706 * multiplier, releaseTime ) ); // Josh
        lockboxes.push( Lockbox( address(0x812f5216aA2a98e498E41b96721fdDD0eb3126FD),  4117647 * multiplier, releaseTime ) ); // Infinity
        lockboxes.push( Lockbox( address(0xa665a0507Ad4B0571B12B1f59FA7e8d2BF63C65F),  2941176 * multiplier, releaseTime ) ); // Bigcoin
        lockboxes.push( Lockbox( address(0x5081fe1872c7A366883F13440281f233399Fa983),  5882353 * multiplier, releaseTime ) ); // Santos
        lockboxes.push( Lockbox( address(0xa778ED6b377e63c3c5806197e7B023576F907e82),  2941176 * multiplier, releaseTime ) ); // Giang
        lockboxes.push( Lockbox( address(0xC1ea53874efD8e6374931a83AeCcdf66d24F70fc),  2941176 * multiplier, releaseTime ) ); // Zet
        lockboxes.push( Lockbox( address(0xa07A669a02E9255F2dAdDf8E35e6ae693e05C31a), 10000000 * multiplier, releaseTime ) ); // Kyros
        lockboxes.push( Lockbox( address(0x73E1C4A448C811c2d6DAa296DE17B2DcD5D7a6e8),  2941176 * multiplier, releaseTime ) ); // fireant
        lockboxes.push( Lockbox( address(0x6a104D55eBC2CEA43E1688e7b75881FE81E0Ff34),  1764706 * multiplier, releaseTime ) ); // enjoymyhobby
        lockboxes.push( Lockbox( address(0x49Dbf3CB9a5e8cd64444a1d0dFADBcb7cb3f65d7),  1764706 * multiplier, releaseTime ) ); // lovejudylee
        lockboxes.push( Lockbox( address(0xE7F64aE5BAf0ed5e494909DC3120EC074C078A14),  1764706 * multiplier, releaseTime ) ); // bitmansour
        lockboxes.push( Lockbox( address(0xd0c9fECc2902A23370fC3b412AFF82f4d64F0D55),  2941176 * multiplier, releaseTime ) ); // Dynastysignal
        lockboxes.push( Lockbox( address(0xd0c9fECc2902A23370fC3b412AFF82f4d64F0D55),  1764706 * multiplier, releaseTime ) ); // PLUTUSBRF
        lockboxes.push( Lockbox( address(0x8732584711014a6cB946750be53e4393d7c0fB9B),  1764706 * multiplier, releaseTime ) ); // coininssa
        lockboxes.push( Lockbox( address(0xDC8b64891C6289faDf0CbFB1077aDdf154Cda6C5),  1764706 * multiplier, releaseTime ) ); // liambitcoin
        // BAD CHECKSUM lockboxes.push( Lockbox( address(0xfa4937670686c09f180c71a9b93e2ffcc3a79f47),  2352941 * multiplier, releaseTime ) ); // cryptopanda
        lockboxes.push( Lockbox( address(0x0e95583bC2EeC4cA637eE6CD1362Aeed3E93af72),  1176471 * multiplier, releaseTime ) ); // Ugh_H
        lockboxes.push( Lockbox( address(0x8dC149Df9FA5d9ac32Ee4BaDbeE14628Ff813766),  1176471 * multiplier, releaseTime ) ); // coindodo
        lockboxes.push( Lockbox( address(0x87454fD733173947042457492073484f4B754252),  1176471 * multiplier, releaseTime ) ); // Community Manager
        // BAD CHECKSUM lockboxes.push( Lockbox( address(0xebc298abd7ccbc0432717dd3350909fba1ff47ad),   588235 * multiplier, releaseTime ) ); // Translator
        lockboxes.push( Lockbox( address(0x430A7eDaf63E73Cb0092F15842172fB52855Cd75),  1764706 * multiplier, releaseTime ) ); // Community Viral
        lockboxes.push( Lockbox( address(0xd999074F947f9813bDD161Fb2452332ac6a4D695),  7647059 * multiplier, releaseTime ) ); // ReBlock
    }

    // Current KOL Terms
    function kol3Allocations( uint releaseTime, uint multiplier ) private {
        lockboxes.push( Lockbox( address(0x56681E9E89509Be94230dd05978021F40B36b4fe),   1960784 * multiplier, releaseTime ) ); // ATC
        lockboxes.push( Lockbox( address(0x7786089B523202B02409A4763eD375E6Fffce464),  23529412 * multiplier, releaseTime ) ); // Sam
        lockboxes.push( Lockbox( address(0x9D73AAD12cE5F41894030Df2B907797986B4a24F),   1960784 * multiplier, releaseTime ) ); // Craig
        lockboxes.push( Lockbox( address(0xae9192aEd587CA74b60805d67c620f0c4972466f),   5882353 * multiplier, releaseTime ) ); // Tenenbaum
        lockboxes.push( Lockbox( address(0x7dF56E485275570456C26F978434D1E53f04644E),   3529412 * multiplier, releaseTime ) ); // Reda
        lockboxes.push( Lockbox( address(0x7097388968619d8AcA95A83c1731dc818faFF43A), 117647059 * multiplier, releaseTime ) ); // SevenX
    }

    function seedAllocations( uint releaseTime, uint multiplier ) private {
        lockboxes.push( Lockbox( address(0x0F935E3E0e3b4b949bDA2B7e2D695777f4D86DbB), 375000000 * multiplier, releaseTime ) ); // Kim
        lockboxes.push( Lockbox( address(0x5F6b7D3Fca66a9B9Bca4A081c6C1D4711Cf5e186), 937500000 * multiplier, releaseTime ) ); // Yoon
        lockboxes.push( Lockbox( address(0xAB84307912AAB8Df647B6c9e60E8F9260E4d92D5), 937500000 * multiplier, releaseTime ) ); // TrustVerse
        lockboxes.push( Lockbox( address(0x17853185836791004683D0314220332ed47D453F), 468750000 * multiplier, releaseTime ) ); // Borderless
        lockboxes.push( Lockbox( address(0x209b94EE294db2Cf2162054e28173aAA07893138), 562500000 * multiplier, releaseTime ) ); // Ditto
    }
}
