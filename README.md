# Opulous ERC20 token and vesting smart contracts







## Testing

FYI https://www.trufflesuite.com/docs/truffle/quickstart

1. Start Ganache
2. Install contracts
	$ truffle migrate
3. Start debugger
	$ truffle console

	$ let tv = await OpulousTokenVesting.deployed();
	$ tv.address
	$ tv.initializeLockboxes({gas:15000000}); 

## Deploy

1. Fresh build
	$ truffle compile --all

2. Publish to Ethereum mainnet
	$ truffle migrate --network mainnet
