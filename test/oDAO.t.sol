// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/interfaces/IMember1155.sol";
import "../src/interfaces/iInstanceDAO.sol";
import "../src/interfaces/IERC20.sol";
import "../src/interfaces/IERC721.sol";

import "../src/oDAO.sol";
import "./mocks/mockERC20.sol";

contract oDao is Test {
    ODAO O;
    IERC20 BaseE20;

    DAOinstance DAO;

    address deployer = address(4896);
    address Agent1 = address(16);
    address Agent2 = address(32);
    address Agent3 = address(48);

    function setUp() public {
        vm.prank(deployer, deployer);
        O = new ODAO();
        BaseE20 = IERC20(address(new M20()));
    }

    function testCreateNewDao() public {
        vm.prank(deployer, deployer);
        DAO = DAOinstance(O.createDAO(address(BaseE20)));

        assertTrue(address(DAO) != address(0));
        assertTrue(DAO.baseID() == uint160(bytes20(address(DAO))));
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
}
