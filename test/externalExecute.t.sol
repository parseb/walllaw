// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./utils/functionality.t.sol";
import "./mocks/mockExternal.sol";

contract CheckTrickle is Test, MyUtils {
    iInstanceDAO DAO;
    MockExternalSameStorageLayout MockExt;
    address mxt;

    constructor() {
        MockExt = new MockExternalSameStorageLayout();
        mxt = address(MockExt);
        DAO = iInstanceDAO(_createDAO(address(BaseE20)));
    }

    function setup() public {
        vm.startPrank(Agent1);

        DAO.wrapMint(1000 ether);
        _setCreateMembrane(address(DAO));
        // _createSubDaos();
        vm.stopPrank();
    }

    function _createSimpleExternalCall() public returns (uint256) {
        return O.createExternalCall(mxt, abi.encodeWithSignature("changeODAOAddress(uint256)", 999999999));
    }

    function testCreateExternalCall() public {
        DAO.mintMembershipToken(Agent1);
        uint256 id = _createSimpleExternalCall();
        skip(10 days);
        assertTrue(id > 0);
        assertTrue(MockExt.baseID() == 5);
        vm.prank(Agent1);
        bool t = DAO.executeExternalLogic(id);
        assertTrue(MockExt.baseID() == 5);
        assertTrue(t);
        assertTrue(DAO.baseID() == 999999999);
    }
}
