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
    uint256 initPerSec = DAO.baseInflationPerSec();
    _setInflation(10);

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
    skip(100);
    uint256 balanceOfSubD0 = IERC20(address(DAO.internalToken())).balanceOf(sD[0]);
    assertTrue(balanceOfSubD0 == 0, "not zero");
    DAO.redistributeSubDAO(sD[0]);
    balanceOfSubD0 = IERC20(address(DAO.internalToken())).balanceOf(sD[0]);
    
    uint256 balanceOfSubD1 = IERC20(address(DAO.internalToken())).balanceOf(sD[1]);
    assertTrue(balanceOfSubD0 > 0, "still 0");
    skip(1);
    DAO.redistributeSubDAO(sD[0]);
    assertTrue( IERC20(address(DAO.internalToken())).balanceOf(sD[0]) - 6295807568 ==  balanceOfSubD0 );
    // assertFalse(balanceOfSubD1 > 0, "still 0");
    // assertTrue(balanceOfSubD0 == balanceOfSubD1, "equal");
}


}
