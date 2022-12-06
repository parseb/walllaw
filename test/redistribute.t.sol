// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./inflation.t.sol";
import "forge-std/Test.sol";

contract RedistributiveTest is Test, redistributiveInflation {

uint basicMembraneId;
uint256 initBaseSupply;

constructor() {
        setUp();
        _createAnERC20();
        basicMembraneId = _createBasicMembrane();
        super.setUp();
        _membraneContext();
        IERC20 baseT  = IERC20(address(DAO.baseTokenAddress()));
        IERC20 internalT = IERC20(address(DAO.internalToken()));
}


function testImportCheck() public {
    assertTrue(address(O) != address(0));
    assertTrue(address(BaseE20) != address(0));
    assertTrue(address(iMR) != address(0));
    assertTrue(address(DAO) != address(0));
}

function _setInflation(uint256 percent_) public {
    vm.prank(Agent1);
    DAO.signalInflation(percent_);
}

function _createSubDaos(uint256 howMany_, address parentDAO_) public returns (address[] memory subDs){
    uint i;
    for (i; i< howMany_; ) {
        O.createSubDAO(_createBasicMembrane(), parentDAO_);
        unchecked { ++i; }
    }
    subDs = O.getDAOsOfToken(DAO.internalTokenAddr());
}

function testSetNewInflation() public {
    testMintsInflation();

    uint256 initInflation = DAO.baseInflationRate();
    _setInflation(10);
    uint256 initPerSec = DAO.baseInflationPerSec();

    if (initInflation == 10 ) _setInflation(10);
    assertFalse(initInflation == DAO.baseInflationRate(), "failed to update infaltion");
    assertTrue(initPerSec != 0, "per sec not updated");
}


function testRedistributes() public {
    testSetNewInflation();
    uint instances = 5;
    uint equalSlice = 100 / instances;
    vm.startPrank(Agent1);
    address[] memory sD = _createSubDaos(5,address(DAO));
    vm.stopPrank();
    uint[] memory distributionAmounts = new uint[](instances);
    
    for (instances; instances > 0;  --instances ) { 
        uint i = instances - 1;
        distributionAmounts[i] = equalSlice;
        assertTrue(sD[i] != address(0), "address 0 spotted");
        }

    vm.prank(Agent1);
    assertTrue( DAO.distributiveSignal(distributionAmounts), 'signaled distribution');
    assertTrue( DAO.getUserReDistribution(Agent1).length == distributionAmounts.length, 'mismatch');

/////////
    console.log( IERC20(address(DAO.internalToken())).balanceOf(address(DAO))); // "balance of donor DAO before skip", 34982966968459
    console.log( DAO.baseInflationPerSec()); // "base inflation per sec:", 31797007921
    skip(100);
    uint256 balanceOfSubD0 = IERC20(address(DAO.internalToken())).balanceOf(sD[0]); //0
    assertTrue(balanceOfSubD0 == 0, "not zero");
    uint basePerSec = DAO.baseInflationPerSec();
    uint balance1 = IERC20(address(DAO.internalToken())).balanceOf(address(DAO));
    console.log( balance1 ); // "balance of donor DAO", 34982966968459
    console.log( basePerSec ); // "base inflation per sec:", 31797007921


    DAO.mintInflation(); // base * 100
    DAO.redistributeSubDAO(sD[0]); // ^ minted  / 20 
    balanceOfSubD0 = IERC20(address(DAO.internalToken())).balanceOf(sD[0]);
    
    uint256 balanceOfSubD1 = IERC20(address(DAO.internalToken())).balanceOf(sD[1]);
    assertTrue(balanceOfSubD0 > 0, "still 0");

    DAO.redistributeSubDAO(sD[0]);
    // assertTrue( IERC20(address(DAO.internalToken())).balanceOf(sD[0]) - 6295807568 ==  balanceOfSubD0 );
    console.log("internal T total supply:", IERC20(DAO.internalToken()).totalSupply());
    console.log("per sec:", DAO.baseInflationPerSec());
    console.log("rate per year:", DAO.baseInflationRate());
    console.log("balance of distributed to 0", IERC20(address(DAO.internalToken())).balanceOf(sD[0]) );

    assertTrue(iInstanceDAO(sD[0]).owner() == Agent1, "init creator is owner");
    assertTrue(iInstanceDAO(sD[1]).owner() == Agent1, "agent1");
    assertTrue(iInstanceDAO(sD[4]).owner() == Agent1, "agent1");
    
    // assertFalse(balanceOfSubD1 > 0, "still 0");
    vm.prank(address(45353434634));
    DAO.redistributeSubDAO(sD[1]);
    balanceOfSubD1 = IERC20(address(DAO.internalToken())).balanceOf(sD[1]);
    // assertTrue(balanceOfSubD1 > 0, "still 0");
    console.log("per sec:", DAO.baseInflationPerSec());
    console.log("rate per year:", DAO.baseInflationRate());
    console.log("balance of distributed to 1", IERC20(address(DAO.internalToken())).balanceOf(sD[1]) );

    uint sub2 = IERC20(address(DAO.internalToken())).balanceOf(sD[2]);
    uint sub3 = IERC20(address(DAO.internalToken())).balanceOf(sD[3]);
    uint sub4 = IERC20(address(DAO.internalToken())).balanceOf(sD[4]);

    assertTrue( sub2 == 0, '0 balance');
    assertTrue(sub2 * 2 == (sub3 + sub4), 'different disperesed amts');

    skip(100);

    DAO.redistributeSubDAO(sD[2]);
    DAO.redistributeSubDAO(sD[3]);
    DAO.redistributeSubDAO(sD[4]);

    sub2 = IERC20(address(DAO.internalToken())).balanceOf(sD[2]);
    sub3 = IERC20(address(DAO.internalToken())).balanceOf(sD[3]);
    sub4 = IERC20(address(DAO.internalToken())).balanceOf(sD[4]);

    assertFalse( sub2 == 0, '0 balance');
    // assertTrue(sub2 * 2 == (sub3 + sub4), 'different disperesed amts');

    console.log('sub2', sub2);
    console.log('sub3', sub3);
    console.log('sub4', sub4);
    
    // assertTrue(sub3 == sub4, 'same claim, diff balance');

}


}
