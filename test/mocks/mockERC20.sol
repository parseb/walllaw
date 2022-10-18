// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/tokens/ERC20.sol";

contract M20 is ERC20("Mock20", "M20", 18) {
    address deployer = address(4896);
    address Agent1 = address(16);
    address Agent2 = address(32);
    address Agent3 = address(48);

    constructor() {
        _mint(deployer, 400_000 ether);
        _mint(Agent1, 100_000 ether);
        _mint(Agent2, 200_000 ether);
        _mint(Agent3, 300_000 ether);
    }
}
