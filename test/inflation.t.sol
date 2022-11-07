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

contract redistributiveInflation is Test {
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


    function _createAnERC20() public returns (address){
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

    function _context() public {
        vm.prank(deployer, deployer);
        address dInstance = address(O.createDAO(address(BaseE20)));
        DAO = DAOinstance(dInstance);
        
        /// active membrane of dInstance
        uint256 currentMembrane;

        currentMembrane = O.inUseMembraneId(dInstance);
        assertTrue(currentMembrane == 0, "has unexpected default membrane");

        address[] memory a = new address[](1);
        uint[] memory u = new uint[](1);

        a[0] =  DAO.baseTokenAddress();
        u[0] = 101_000;
        uint membrane1 = O.createMembrane(a,u,bytes("url://deployer_hasaccessmeta"));

        O.setMembrane(dInstance, membrane1);

        assertTrue((O.inUseMembraneId(dInstance) == membrane1), "failed to set");

    }

    //// #######################################

    function testMintsInflation() public {
        _context();
        uint startInflation = DAO.baseInflationRate();
        uint startPerSec = DAO.baseInflationPerSec(); 
        IERC20 internalT = IERC20(DAO.internalToken());
        IERC20 baseT = IERC20(DAO.baseTokenAddress());

        assertTrue(startInflation == ( DAO.baseID() % 100 ), "unexpected start % infl");
        assertTrue(startPerSec == 0, "not 0");
        assertTrue(iMR.balanceOf(Agent1, DAO.baseID()) == 0, "agent1 already member");
        assertTrue(DAO.mintMembershipToken(Agent1), "mint failed");

        assertTrue(internalT.balanceOf(Agent1) == 0, "has internal balance");
        vm.startPrank(Agent1);
        assertTrue( baseT.approve(address(DAO), type(uint256).max), "approve f");
        DAO.wrapMint(10 * 1 ether);
        assertTrue(internalT.balanceOf(Agent1) != 0, "does not have internal balance");

        uint newInflation = DAO.signalInflation(2);
        assertTrue(newInflation == DAO.baseInflationRate(), "unexpected inflation");
        vm.stopPrank();
        
        assertTrue( startInflation != DAO.baseInflationRate(), "samo1");
        assertTrue( startPerSec != DAO.baseInflationPerSec(), "samo2");
        skip(2000);
        
        uint minted = DAO.mintInflation();
        assertTrue(minted == (DAO.baseInflationPerSec() * 2000),"math went wrong");

    }

}