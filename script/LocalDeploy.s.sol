// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/oDAO.sol";
import "src/Member1155.sol";
import "test/mocks/mockERC20.sol";

contract LocalDeploy is Script {
    ODAO O;
    M20 Mock20;
    MemberRegistry M;

    function setUp() public {

        M = new MemberRegistry();
        Mock20 = new M20();
    }

    function run() public {
        vm.startBroadcast();
        Mock20.totalSupply();
        vm.stopBroadcast();
    }
}
