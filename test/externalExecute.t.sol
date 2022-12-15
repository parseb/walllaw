// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./utils/functionality.t.sol";
import "./mocks/mExtern.sol";

contract ExternalCall is Test, MyUtils {
    iInstanceDAO DAO;
    DelegStore MockExt;
    address mxt;

    constructor() {
        MockExt = new DelegStore();
        mxt = address(MockExt);
        DAO = iInstanceDAO(_createDAO(address(BaseE20)));
    }

    // function setUp() public {
    //     vm.startPrank(Agent1);

    //     IDAO20(DAO.internalTokenAddress()).wrapMint(1000 ether);
    //     _setCreateMembrane(address(DAO));
    //     // _createSubDaos();
    //     vm.stopPrank();
    // }

    function _createSimpleExternalCall() public returns (uint256) {
        return iLG.createExternalCall(mxt, abi.encodeWithSignature("changeODAOAddress(uint256)", 999999999));
    }

    function testCreateExternalCall() public {
        DAO.mintMembershipToken(Agent1);
        vm.prank(Agent1, Agent1); // tx.origin
        uint256 id = _createSimpleExternalCall();

        assertTrue(id > 0);
        assertTrue(MockExt.baseID() == 5);

        vm.prank(Agent1);
        vm.expectRevert(); //"NonR()"
        bool t = DAO.executeExternalLogic(id);

        vm.prank(Agent1);
        skip(1 days);
        vm.expectRevert(); // "NonR()"
        t = DAO.executeExternalLogic(id);

        vm.prank(Agent2);
        skip(4 days);
        vm.expectRevert(); // "DAOinstance__NotMember()"
        t = DAO.executeExternalLogic(id);
        assertFalse(t);

        vm.prank(Agent2);
        DAO.mintMembershipToken(Agent2);
        skip(4 days);
        vm.expectRevert(); // "DAOinstance__NotMember()"
        t = DAO.executeExternalLogic(id);
        assertFalse(t);

        assertTrue(MockExt.baseID() == 5);

        vm.prank(Agent1, Agent1);
        skip(6 days);
        t = DAO.executeExternalLogic(id);

        assertTrue(t);
        assertTrue(DAO.baseID() == 999999999);
    }
}
