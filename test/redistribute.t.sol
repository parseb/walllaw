// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "./utils/functionality.t.sol";

contract RedistributiveTest is Test, MyUtils {
    uint256 basicMembraneId;
    uint256 initBaseSupply;
    uint256 initPerSec;
    IDAO20 internalT;
    IERC20 baseT;
    iInstanceDAO DAO;
    address[] subDaos;

    function setUp() public {
        baseT = IERC20(_createAnERC20());
        vm.prank(deployer);
        DAO = iInstanceDAO(_createDAO(address(baseT)));
        internalT = IDAO20(DAO.internalTokenAddress());

        iMB = IMembrane(iMR.MembraneRegistryAddress());
    }

    function testRedistrubutes() public {
        /// nrOfSubDaos to fuzz
        vm.startPrank(Agent1);

        DAO.mintMembershipToken(Agent1);
        subDaos = _createSubDaos(5, address(DAO));
        assertTrue(internalT.balanceOf(Agent1) == 0);
        baseT.approve(address(internalT), type(uint256).max);
        internalT.wrapMint(100 ether);
        skip(100);
        DAO.signalInflation(50);
        internalT.wrapMint(100 ether);
        uint256[] memory distributiveSignal = new uint256[](5);
        distributiveSignal[0] = 2000;
        distributiveSignal[1] = 2000;
        distributiveSignal[2] = 2000;
        distributiveSignal[3] = 2000;
        distributiveSignal[4] = 2000;

        DAO.distributiveSignal(distributiveSignal);
        skip(365);

        uint256 balance1 = internalT.balanceOf(subDaos[0]);
        uint256 balance2 = internalT.balanceOf(subDaos[1]);
        uint256 balance5 = internalT.balanceOf(subDaos[4]);

        assertTrue(balance1 + balance2 + balance5 == 0);

        DAO.redistributeSubDAO(subDaos[0]);
        assertTrue(balance1 < internalT.balanceOf(subDaos[0]));
        assertTrue(balance2 == internalT.balanceOf(subDaos[1]));
        DAO.redistributeSubDAO(subDaos[1]);
        assertTrue(balance2 < internalT.balanceOf(subDaos[1]));
        assertTrue(internalT.balanceOf(subDaos[0]) == internalT.balanceOf(subDaos[1]));

        skip(3);
        DAO.redistributeSubDAO(subDaos[4]);
        assertTrue(balance5 < internalT.balanceOf(subDaos[4]));
        balance2 = internalT.balanceOf(subDaos[1]);
        balance5 = internalT.balanceOf(subDaos[4]);

        /// ###
        assertTrue(balance5 > balance2 + ((DAO.baseInflationPerSec() / 5) * 2));
        assertFalse(balance5 > balance2 + ((DAO.baseInflationPerSec() / 5) * 3));

        vm.stopPrank();
    }

    function testIsOnlyMember0Balance() public {
        vm.startPrank(Agent1);

        DAO.mintMembershipToken(Agent1);

        uint256 startI = DAO.baseInflationRate();

        if (startI != 99) {
            DAO.signalInflation(99);
            assertTrue(DAO.baseInflationRate() == 99, "f to set inflation");
            assertTrue(DAO.baseInflationPerSec() == 0, "fake base per sec");
        }

        skip(1);
        uint256 membrane1 = iMB.inUseMembraneId(address(DAO));
        DAO.changeMembrane(_createBasicMembrane());
        uint256 membrane2 = iMB.inUseMembraneId(address(DAO));
        assertTrue(membrane1 != membrane2, "failed to change membrane");

        //// @dev assumed all majoritarian functions execute of 0 balance
        vm.stopPrank();
    }

    function testGetsIndecisionsInfl() public {
        // _mint(0x323525cB37428d72e33B8a3d9a72F848d08Bf2B7, 300_000 ether);
        // _mint(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC, 300_000 ether);
        // _mint(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266), 200_000 ether);
        vm.prank(0x323525cB37428d72e33B8a3d9a72F848d08Bf2B7);
        IERC20(DAO.baseTokenAddress()).approve(DAO.internalTokenAddress(), type(uint256).max - 1);
        vm.prank(0x323525cB37428d72e33B8a3d9a72F848d08Bf2B7);
        DAO.mintMembershipToken(0x323525cB37428d72e33B8a3d9a72F848d08Bf2B7);
        vm.prank(0x323525cB37428d72e33B8a3d9a72F848d08Bf2B7);
        IDAO20(DAO.internalTokenAddress()).wrapMint(100 ether);

        vm.prank(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        IERC20(DAO.baseTokenAddress()).approve(DAO.internalTokenAddress(), type(uint256).max - 1);
        vm.prank(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        DAO.mintMembershipToken(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        vm.prank(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        IDAO20(DAO.internalTokenAddress()).wrapMint(100 ether);

        vm.prank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        IERC20(DAO.baseTokenAddress()).approve(DAO.internalTokenAddress(), type(uint256).max - 1);
        vm.prank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        DAO.mintMembershipToken(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        vm.prank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        IDAO20(DAO.internalTokenAddress()).wrapMint(300 ether);

        vm.prank(0x323525cB37428d72e33B8a3d9a72F848d08Bf2B7);
        DAO.signalInflation(99);

        Indecision[] memory Is = DAO.getAllActiveIndecisions();

        assertTrue(Is.length == 1, "Expected lenght 1");
        assertTrue(Is[0].id == 99, "Expected 99 inflation active indecision");

        vm.prank(0x323525cB37428d72e33B8a3d9a72F848d08Bf2B7);
        DAO.signalInflation(98);
        Is = DAO.getAllActiveIndecisions();
        assertTrue(Is[1].id == 98, "Expected 98888");
        assertTrue(Is.length == 2, "Expected lenght 2");

        vm.prank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        DAO.signalInflation(98);

        Is = DAO.getAllActiveIndecisions();
        assertTrue(Is[1].id == 98, "Expected 98888");
        assertTrue(Is.length == 2, "Expected lenght 2");

        DAO.scrubIndecisions();
        Is = DAO.getAllActiveIndecisions();
        assertTrue(Is[1].id == 98, "Expected 98888");
        assertTrue(Is.length == 2, "Expected lenght 2");

        ///

        address[] memory Ms = iMR.getctiveMembersOf(address(DAO));
        assertTrue(Ms.length > 0, "no members retrieved");

        /// test post exec wipe

        ////
        // uint256 initInflation = DAO.baseInflationRate();
        // _setInflation(10, address(DAO));
        // uint256 initPerSec = DAO.baseInflationPerSec();

        // assertFalse(initInflation == DAO.baseInflationRate(), "failed to update infaltion");
        // assertTrue(initPerSec != 0, "per sec not updated");
    }

    // function testRedistributes() public {
    //     testSetNewInflation();
    //     uint256 instances = 5;
    //     uint256 equalSlice = 100 / instances;
    //     vm.startPrank(Agent1);
    //     address[] memory sD = _createSubDaos(5, address(DAO));
    //     vm.stopPrank();
    //     uint256[] memory distributionAmounts = new uint[](instances);

    //     for (instances; instances > 0; --instances) {
    //         uint256 i = instances - 1;
    //         distributionAmounts[i] = equalSlice;
    //         assertTrue(sD[i] != address(0), "address 0 spotted");
    //     }
    // }
}

// contract RedistributiveTest is Test, inflationtest  {
//     uint256 basicMembraneId;
//     uint256 initBaseSupply;

//     constructor() {
//         setUp();
//         _createAnERC20();
//         basicMembraneId = _createBasicMembrane(1);
//         super.setUp();
//         _membraneContext();
//         IERC20 baseT = IERC20(address(DAO.baseTokenAddress()));
//         IERC20 internalT = IERC20(address(DAO.internalToken()));
//     }

//     function _setInflation(uint256 percent_) public {
//         vm.prank(Agent1);
//         DAO.signalInflation(percent_);
//     }

//     function _createSubDaos(uint256 howMany_, address parentDAO_) public returns (address[] memory subDs) {
//         uint256 i;
//         for (i; i < howMany_;) {
//             O.createSubDAO(_createBasicMembrane(0), parentDAO_);
//             unchecked {
//                 ++i;
//             }
//         }
//         subDs = O.getDAOsOfToken(DAO.internalTokenAddress());
//     }

//     function testSetNewInflation() public {
//         testMintsInflation();

//         uint256 initInflation = DAO.baseInflationRate();
//         _setInflation(10);
//         uint256 initPerSec = DAO.baseInflationPerSec();

//         if (initInflation == 10) _setInflation(10);
//         assertFalse(initInflation == DAO.baseInflationRate(), "failed to update infaltion");
//         assertTrue(initPerSec != 0, "per sec not updated");
//     }

//     function testRedistributes() public {
//         testSetNewInflation();
//         uint256 instances = 5;
//         uint256 equalSlice = 100 / instances;
//         vm.startPrank(Agent1);
//         address[] memory sD = _createSubDaos(5, address(DAO));
//         vm.stopPrank();
//         uint256[] memory distributionAmounts = new uint[](instances);

//         for (instances; instances > 0; --instances) {
//             uint256 i = instances - 1;
//             distributionAmounts[i] = equalSlice;
//             assertTrue(sD[i] != address(0), "address 0 spotted");
//         }
// contract RedistributiveTest is Test, inflationtest  {
//     uint256 basicMembraneId;
//     uint256 initBaseSupply;

//     constructor() {
//         setUp();
//         _createAnERC20();
//         basicMembraneId = _createBasicMembrane(1);
//         super.setUp();
//         _membraneContext();
//         IERC20 baseT = IERC20(address(DAO.baseTokenAddress()));
//         IERC20 internalT = IERC20(address(DAO.internalToken()));
//     }

//     function _setInflation(uint256 percent_) public {
//         vm.prank(Agent1);
//         DAO.signalInflation(percent_);
//     }

//     function _createSubDaos(uint256 howMany_, address parentDAO_) public returns (address[] memory subDs) {
//         uint256 i;
//         for (i; i < howMany_;) {
//             O.createSubDAO(_createBasicMembrane(0), parentDAO_);
//             unchecked {
//                 ++i;
//             }
//         }
//         subDs = O.getDAOsOfToken(DAO.internalTokenAddress());
//     }

//     function testSetNewInflation() public {
//         testMintsInflation();

//         uint256 initInflation = DAO.baseInflationRate();
//         _setInflation(10);
//         uint256 initPerSec = DAO.baseInflationPerSec();

//         if (initInflation == 10) _setInflation(10);
//         assertFalse(initInflation == DAO.baseInflationRate(), "failed to update infaltion");
//         assertTrue(initPerSec != 0, "per sec not updated");
//     }

//     function testRedistributes() public {
//         testSetNewInflation();
//         uint256 instances = 5;
//         uint256 equalSlice = 100 / instances;
//         vm.startPrank(Agent1);
//         address[] memory sD = _createSubDaos(5, address(DAO));
//         vm.stopPrank();
//         uint256[] memory distributionAmounts = new uint[](instances);

//         for (instances; instances > 0; --instances) {
//             uint256 i = instances - 1;
//             distributionAmounts[i] ibution(Agent1).length == distributionAmounts.length, "mismatch");

//         /////////
//         console.log(IERC20(address(DAO.internalToken())).balanceOf(address(DAO))); // "balance of donor DAO before skip", 34982966968459
//         console.log(DAO.baseInflationPerSec()); // "base inflation per sec:", 31797007921
//         skip(100);
//         uint256 balanceOfSubD0 = IERC20(address(DAO.internalToken())).balanceOf(sD[0]); //0
//         assertTrue(balanceOfSubD0 == 0, "not zero");
//         uint256 basePerSec = DAO.baseInflationPerSec();
//         uint256 balance1 = IERC20(address(DAO.internalToken())).balanceOf(address(DAO));
//         console.log(balance1); // "balance of donor DAO", 34982966968459
//         console.log(basePerSec); // "base inflation per sec:", 31797007921

//         DAO.mintInflation(); // base * 100
//         DAO.redistributeSubDAO(sD[0]); // ^ minted  / 20
//         balanceOfSubD0 = IERC20(address(DAO.internalToken())).balanceOf(sD[0]);

//         uint256 balanceOfSubD1 = IERC20(address(DAO.internalToken())).balanceOf(sD[1]);
//         assertTrue(balanceOfSubD0 > 0, "still 0");

//         DAO.redistributeSubDAO(sD[0]);
//         // assertTrue( IERC20(address(DAO.internalToken())).balanceOf(sD[0]) - 6295807568 ==  balanceOfSubD0 );
//         console.log("internal T total supply:", IERC20(DAO.internalToken()).totalSupply());
//         console.log("per sec:", DAO.baseInflationPerSec());
//         console.log("rate per year:", DAO.baseInflationRate());
//         console.log("balance of distributed to 0", IERC20(address(DAO.internalToken())).balanceOf(sD[0]));

//         assertTrue(iInstanceDAO(sD[0]).owner() == Agent1, "init creator is owner");
//         assertTrue(iInstanceDAO(sD[1]).owner() == Agent1, "agent1");
//         assertTrue(iInstanceDAO(sD[4]).owner() == Agent1, "agent1");

//         // assertFalse(balanceOfSubD1 > 0, "still 0");
//         vm.prank(address(45353434634));
//         DAO.redistributeSubDAO(sD[1]);
//         balanceOfSubD1 = IERC20(address(DAO.internalToken())).balanceOf(sD[1]);
//         // assertTrue(balanceOfSubD1 > 0, "still 0");
//         console.log("per sec:", DAO.baseInflationPerSec());
//         console.log("rate per year:", DAO.baseInflationRate());
//         console.log("balance of distributed to 1", IERC20(address(DAO.internalToken())).balanceOf(sD[1]));

//         uint256 sub2 = IERC20(address(DAO.internalToken())).balanceOf(sD[2]);
//         uint256 sub3 = IERC20(address(DAO.internalToken())).balanceOf(sD[3]);
//         uint256 sub4 = IERC20(address(DAO.internalToken())).balanceOf(sD[4]);

//         assertTrue(sub2 == 0, "0 balance");
//         assertTrue(sub2 * 2 == (sub3 + sub4), "different disperesed amts");

//         skip(100);

//         DAO.redistributeSubDAO(sD[2]);
//         DAO.redistributeSubDAO(sD[3]);
//         DAO.redistributeSubDAO(sD[4]);

//         sub2 = IERC20(address(DAO.internalToken())).balanceOf(sD[2]);
//         sub3 = IERC20(address(DAO.internalToken())).balanceOf(sD[3]);
//         sub4 = IERC20(address(DAO.internalToken())).balanceOf(sD[4]);

//         assertFalse(sub2 == 0, "0 balance");
//         // assertTrue(sub2 * 2 == (sub3 + sub4), 'different disperesed amts');

//         console.log("sub2", sub2);
//         console.log("sub3", sub3);
//         console.log("sub4", sub4);

//         assertTrue(sub3 == sub4, 'same claim, diff balance');
//     }
