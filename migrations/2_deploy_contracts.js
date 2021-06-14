const OpulousToken = artifacts.require("OpulousToken");
const OpulousTokenVesting = artifacts.require("OpulousTokenVesting");

module.exports = async function(deployer) {
    await deployer.deploy( OpulousToken, 100000000 ); // 100M tokens x 10^18
    await deployer.deploy( OpulousTokenVesting, OpulousToken.address );
};