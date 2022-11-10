// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/oDAO.sol";
import "test/mocks/mockERC20.sol";

contract LocalDeploy is Script {
    ODAO O;
    M20 Mock20;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        O = new ODAO();
        Mock20 = new M20();
        vm.stopBroadcast();
    }
}
