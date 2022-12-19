// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "solmate/tokens/ERC20.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract M20 is ERC20("Mock20", "M20") {
    address deployer = address(4896);
    address Agent1 = address(16);
    address Agent2 = address(32);
    address Agent3 = address(48);

    constructor() {

        _mint(address(0xb3F204a5F3dabef6bE51015fD57E307080Db6498), 10_000_000 ether);
        _mint(msg.sender, 1_000_000 ether);
        _mint(deployer, 400_000 ether);
        _mint(Agent1, 100_000 ether);
        _mint(Agent2, 200_000 ether);
        _mint(Agent3, 300_000 ether);
        _mint(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266), 200_000 ether);
    }
}
