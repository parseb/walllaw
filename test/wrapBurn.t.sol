// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./utils/functionality.t.sol";

contract reageQuit is Test, MyUtils {
    /// like ragequit, withrdawals bubble up but not sideways
    iInstanceDAO DAO;
    IDAO20 internalT;
    IERC20 baseT;

    constructor() {
        baseT = IERC20(new M20());
    }

    function setUp() public {
        vm.startPrank(Agent2);
        DAO = iInstanceDAO(_createDAO(address(baseT)));
        internalT = IDAO20(DAO.internalTokenAddress());
        baseT = IERC20(DAO.baseTokenAddress());
        baseT.approve(address(internalT), type(uint256).max);
        internalT.wrapMint(1000 ether);
        vm.stopPrank();

        _setCreateMembrane(address(DAO));
    }

    function testSimpleMint() public {
        uint256 howM = 12423423253453453535;
        assertTrue(address(baseT) != address(internalT));
        uint256 b0 = internalT.balanceOf(Agent3);
        assertTrue(b0 == 0, "should not have balance");
        vm.prank(Agent3, Agent3);
        baseT.approve(address(internalT), type(uint256).max);
        console.log("I approve: ", internalT.base());
        vm.prank(Agent3, Agent3);
        internalT.wrapMint(howM);
        uint256 b1 = internalT.balanceOf(Agent3);
        assertTrue(b1 >= howM, "should now have balance");
    }

    function testSimpleBurn() public {}
}
