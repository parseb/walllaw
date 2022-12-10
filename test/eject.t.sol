// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./utils/functionality.t.sol";
import "./mocks/mExtern.sol";

contract EjectFunctionality is Test, MyUtils {
    /// like ragequit, withrdawals bubble up but not sideways
    iInstanceDAO DAO;
    DelegStore MockExt;
    address mxt;

    constructor() {
        MockExt = new DelegStore();
        mxt = address(MockExt);
        DAO = iInstanceDAO(_createDAO(address(BaseE20)));
    }

    function setup() public {
        vm.startPrank(Agent1);

        IDAO20(DAO.internalTokenAddress()).wrapMint(1000 ether);
        _setCreateMembrane(address(DAO));
        // _createSubDaos();
        vm.stopPrank();
    }
}
