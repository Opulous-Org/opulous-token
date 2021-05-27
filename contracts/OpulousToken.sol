// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OpulousToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("OpulousToken", "OPUL") {
        _mint(msg.sender, initialSupply);
    }
}