// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/interfaces/IMember1155.sol";
import "../src/interfaces/iInstanceDAO.sol";
import "../src/interfaces/IERC20.sol";
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
        vm.prank(deployer);
        DAO.giveOwnership(Agent1);
        assertFalse(DAO.owner() == Agent1);
        vm.prank(deployer);
        DAO.giveOwnership(Agent1);
        assertTrue(DAO.owner() == Agent1);
    }

    function sudoMintMembership(address DAO_, address to_) public {
        uint256 id = uint160(bytes20(DAO_));
        iMR.makeMember(to_, id);
        assertTrue(iMR.balanceOf(to_, id) == 1, "isNotCoreMember");
    }

    function createBasicMembrane() public returns (uint256 basicMid) {
        Membrane memory Mmm;
        address[] memory tokens_ = new address[](1);
        uint256[] memory balances_ = new uint[](1);

        tokens_[0] = address(BaseE20);
        balances_[0] = uint256(1000);

        basicMid = O.createMembrane(tokens_, balances_, bytes("veryMeta"));
    }

    function testCreatesSubDAO() public {
        iInstanceDAO DI = iInstanceDAO(testCreateNewDao());
        // vm.prank(deployer,deployer);
        // DI.giveOwnership(Agent2);
        // vm.prank(deployer,deployer);
        // DI.giveOwnership(Agent2);

        uint256 membraneID = createBasicMembrane();
        vm.expectRevert();
        address subDAOaddr = O.createSubDAO(membraneID, address(DI));
        vm.prank(deployer, deployer);
        DI.mintMembershipToken(Agent1);
        vm.prank(Agent1);
        subDAOaddr = O.createSubDAO(membraneID, address(DI));
        assertTrue(subDAOaddr != address(0), "subdao is 0");
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

        // vm.expectRevert();
        // /// unatisfied token balances
        // assertFalse(DI.mintMembershipToken(address(991)));
    }
}
