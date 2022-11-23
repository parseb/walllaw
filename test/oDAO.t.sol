// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/interfaces/IMember1155.sol";
import "../src/interfaces/iInstanceDAO.sol";
// import "../src/interfaces/IERC20.sol";
import "../src/interfaces/IERC721.sol";

import "../src/oDAO.sol";
import "../src/Member1155.sol";
import "./mocks/mockERC20.sol";

contract oDao is Test {
    ODAO O;
    IERC20 BaseE20;
    IMemberRegistry iMR;

    DAOinstance DAO;

    address deployer = address(4896);
    address Agent1 = address(16);
    address Agent2 = address(32);
    address Agent3 = address(48);

    function setUp() public {
        vm.prank(deployer, deployer);
        O = new ODAO();
        BaseE20 = IERC20(address(new M20()));
        iMR = IMemberRegistry(O.getMemberRegistryAddr());
    }

    function _createAnERC20() public returns (address) {
        return address(new M20());
    }

    function _createBasicMembrane() public returns (uint256 basicMid) {
        Membrane memory Mmm;
        address[] memory tokens_ = new address[](1);
        uint256[] memory balances_ = new uint[](1);

        tokens_[0] = address(BaseE20);
        balances_[0] = uint256(1000);

        basicMid = O.createMembrane(tokens_, balances_, bytes("veryMeta"));
    }

    function testCreateNewDao() public returns (address Dinstnace) {
        vm.prank(deployer, deployer);
        Dinstnace = address(O.createDAO(address(BaseE20)));
        DAO = DAOinstance(Dinstnace);

        assertTrue(address(DAO) != address(0));
        // assertTrue(DAO.baseID() == uint160(bytes20(address(DAO))));
        assertTrue(DAO.owner() == deployer);
    }

    function testTransferOwnership() public {
        testCreateNewDao();

        assertTrue(DAO.owner() == deployer);
        vm.prank(deployer, deployer);
        BaseE20.approve(address(DAO), type(uint256).max - 1);
        vm.prank(deployer);
        DAO.giveOwnership(Agent1);
        assertFalse(DAO.owner() == Agent1);
        vm.prank(deployer);
        DAO.giveOwnership(Agent1);
        assertTrue(DAO.owner() == Agent1);
    }

    function testCreatesSubDAO() public {
        iInstanceDAO DI = iInstanceDAO(testCreateNewDao());
        // vm.prank(deployer,deployer);
        // DI.giveOwnership(Agent2);
        // vm.prank(deployer,deployer);
        // DI.giveOwnership(Agent2);

        uint256 membraneID = _createBasicMembrane();
        vm.expectRevert();
        address subDAOaddr = O.createSubDAO(membraneID, address(DI));
        vm.prank(deployer, deployer);
        DI.mintMembershipToken(Agent1);
        vm.prank(Agent1);
        subDAOaddr = address(O.createSubDAO(membraneID, address(DI)));
        assertTrue(subDAOaddr != address(0), "subdao is 0");

        assertTrue(O.inUseMembraneId(subDAOaddr) != 0, "Has no membrane");
    }

    function testAddMembertoDAO() public {
        iInstanceDAO DI = iInstanceDAO(testCreateNewDao());

        assertFalse(iMR.balanceOf(deployer, DI.baseID()) == 1, "isNotCoreMember");
        assertTrue(O.getDAOfromID(DI.baseID()) == address(DI), "NOT!!!");

        assertTrue(iMR.balanceOf(Agent2, DI.baseID()) == 0, "is alreadly member");
        DI.mintMembershipToken(Agent2);
        assertTrue(iMR.balanceOf(Agent2, DI.baseID()) == 1, "not member");
        vm.expectRevert();
        /// "AlreadyIn()"
        DI.mintMembershipToken(Agent2);

        // unatisfied token balances
        // assertFalse(DI.mintMembershipToken(address(934591)));
    }

    function testChangesMembrane() public {
        vm.prank(deployer, deployer);
        address dInstance = address(O.createDAO(address(BaseE20)));
        DAO = DAOinstance(dInstance);

        /// active membrane of dInstance
        uint256 currentMembrane;

        currentMembrane = O.inUseMembraneId(dInstance);
        assertTrue(currentMembrane == 0, "has unexpected default membrane");

        address[] memory a = new address[](1);
        uint256[] memory u = new uint[](1);

        a[0] = DAO.baseTokenAddress();
        u[0] = 101_000;
        uint256 membrane1 = O.createMembrane(a, u, bytes("url://deployer_hasaccessmeta"));

        vm.prank(Agent3);
        IERC20 token2 = IERC20(_createAnERC20());

        a[0] = address(token2);
        u[0] = 101_000;
        uint256 membrane2 = O.createMembrane(a, u, bytes("url://deployer_noaccess"));
        assertTrue(DAO.owner() == deployer, "owned not deployer");

        vm.expectRevert(); // membraneNotFound();
        O.setMembrane(dInstance, 2121);

        O.setMembrane(dInstance, membrane1);
        assertTrue((O.inUseMembraneId(dInstance) == membrane1), "failed to set");
        /// #### 1

        vm.prank(Agent3, Agent3);
        BaseE20.approve(dInstance, type(uint256).max);

        vm.prank(Agent3, Agent3);
        DAO.wrapMint(10000099999999999);

        vm.prank(address(343), address(343));
        DAO.mintMembershipToken(Agent3);

        assertTrue((O.inUseMembraneId(dInstance) == membrane1), "failed to set");
        vm.prank(Agent3, Agent3);
        DAO.changeMembrane(membrane1);
        assertTrue((O.inUseMembraneId(dInstance) == membrane1), "failed to set");

        //// basic interest rate flip
        uint256 newInteresRate;
        console.log("##############################################");
        vm.prank(Agent1, Agent1);
        vm.expectRevert();
        /// DAOinstance__NotMember()
        newInteresRate = DAO.signalInflation(5);

        vm.prank(Agent3, Agent3);
        newInteresRate = DAO.signalInflation(5);
        assertTrue(DAO.baseInflationRate() == 5, "inconsistent");
        assertTrue(DAO.baseInflationPerSec() != 0, "not persec 0");

        IERC20 internalT = IERC20(DAO.internalToken());
        // assertTrue(internalT.totalSupply() == 100000);

        vm.startPrank(Agent1, Agent1);
        BaseE20.approve(dInstance, type(uint256).max);
        DAO.wrapMint(3144960000 * 10000000);
        vm.stopPrank();

        // assertTrue(DAO.baseInflationPerSec() != 0, "not persec 0");

        vm.prank(Agent3, Agent3);
        vm.expectRevert(); // [FAIL. Reason: >100!]
        newInteresRate = DAO.signalInflation(101);
        DAO.mintMembershipToken(Agent1);

        vm.prank(Agent1, Agent1);
        newInteresRate = DAO.signalInflation(0);

        assertTrue(DAO.baseInflationRate() == 0, "inconsistent");
        assertTrue(DAO.baseInflationPerSec() == 0, "not persec 0");

        /// gCheck

        assertTrue(DAO.gCheck(Agent1), "expected Agent1 to be g");
        assertFalse(DAO.gCheck(address(33335433)));

        IERC20 token3 = IERC20(_createAnERC20());
        a[0] = address(token3);
        u[0] = 4294967294;
        uint256 membrane3 = O.createMembrane(a, u, bytes("url://deployer_noaccess"));

        vm.prank(Agent1, Agent1);
        token3.approve(address(this), type(uint256).max);
        token3.transferFrom(Agent1, address(111), token3.balanceOf(Agent1));
        assertTrue(token3.balanceOf(Agent1) == 0, "still has banalce");

        vm.prank(Agent1, Agent1);
        DAO.changeMembrane(membrane3);

        assertFalse(DAO.gCheck(Agent1), "expected Agent1 to be g");
        assertFalse(DAO.gCheck(address(111)));

        /// #### test tipping point
    }

    // function testCreatesMultipleSubDAO() public {
    //     iInstanceDAO DI = iInstanceDAO(testCreateNewDao());

    //     uint256 membraneID = _createBasicMembrane();
    //     vm.expectRevert();
    //     address subDAOaddr = O.createSubDAO(membraneID, address(DI));
    //     vm.prank(deployer, deployer);
    //     DI.mintMembershipToken(Agent1);
    //     vm.prank(Agent1);
    //     subDAOaddr = address(O.createSubDAO(membraneID, address(DI)));
    //     assertTrue(subDAOaddr != address(0), "subdao is 0");

    //     vm.prank(Agent1);
    //     subDAOaddr = address(O.createSubDAO(membraneID, address(DI)));
    //     assertTrue(subDAOaddr != address(0), "subdao is 0");

    //     assertTrue(O.inUseMembraneId(subDAOaddr) != 0, "Has no membrane");
    // }
}
