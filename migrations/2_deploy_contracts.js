const OpulousToken = artifacts.require("OpulousToken");
const OpulousTokenVesting = artifacts.require("OpulousTokenVesting");

module.exports = async function(deployer) {
    await deployer.deploy( OpulousToken, 100000000 ); // 100M tokens
    await deployer.deploy( OpulousTokenVesting, OpulousToken.address );
    // {
    	//gas: 15000000,			// 15M current limits 
    	//gasPrice: 50000000000	// gwei
    //});
};