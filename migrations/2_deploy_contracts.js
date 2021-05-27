const OpulousToken = artifacts.require("OpulousToken");
const OpulousTokenVesting = artifacts.require("OpulousTokenVesting");

module.exports = async function(deployer) {
    await deployer.deploy( OpulousToken );
    await deployer.deploy( OpulousTokenVesting );
};