// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import "../src/interfaces/IMember1155.sol";
import "./utils/functionality.t.sol";
import "../src/utils/libSafeFactoryAddresses.sol";

contract EndpointSafeTest is Test, MyUtils {
    /// like ragequit, withrdawals bubble up but not sideways
    /// trickels through redistribute subDAo and feedMe

    iInstanceDAO DAO;
    IDAO20 internalT;
    IERC20 baseT;

    address[3] endpoints;
    address[3] agents;
    address[3] subDS;

    iInstanceDAO D1d;
    iInstanceDAO D2d;
    iInstanceDAO D3d;

    IDAO20 D1t;
    IDAO20 D2t;
    IDAO20 D3t;
    uint256 basicMembrane;

    IDAO20 D1Parent;
    IDAO20 D2Parent;
    IDAO20 D3Parent;

    constructor() {
        baseT = IERC20(new M20());
    }

    function setUp() public {
        vm.prank(deployer);
        DAO = iInstanceDAO(_createDAO(address(baseT)));

        vm.startPrank(Agent1);
        internalT = IDAO20(DAO.internalTokenAddress());
        baseT = IERC20(DAO.baseTokenAddress());
        baseT.approve(address(internalT), type(uint256).max);
        internalT.wrapMint(1000 ether);

        vm.stopPrank();
        vm.prank(Agent1);
        DAO.mintMembershipToken(Agent1);
        vm.prank(Agent2);
        DAO.mintMembershipToken(Agent2);
        vm.prank(Agent3);
        DAO.mintMembershipToken(Agent3);

        agents = [Agent1, Agent2, Agent3];

        vm.prank(Agent1);
        basicMembrane = _createBasicMembrane();

        vm.prank(Agent1);
        subDS[0] = O.createSubDAO(basicMembrane, address(DAO));
        vm.prank(Agent2);
        subDS[1] = O.createSubDAO(basicMembrane, address(DAO));
        vm.prank(Agent3);
        subDS[2] = O.createSubDAO(basicMembrane, address(DAO));

        for (uint256 i; i < 3;) {
            vm.prank(agents[i]);
            address sub = O.createSubDAO(uint160(address(agents[i])), subDS[i]);
            endpoints[i] = sub;
            unchecked {
                ++i;
            }
        }

        D1d = iInstanceDAO(endpoints[0]);
        D2d = iInstanceDAO(endpoints[1]);
        D3d = iInstanceDAO(endpoints[2]);

        D1t = IDAO20(D1d.internalTokenAddress());
        D2t = IDAO20(D2d.internalTokenAddress());
        D3t = IDAO20(D3d.internalTokenAddress());

        D1Parent = IDAO20(D1d.baseTokenAddress());
        D2Parent = IDAO20(D2d.baseTokenAddress());
        D3Parent = IDAO20(D3d.baseTokenAddress());
    }

    function _createSafeEndpointFor(address parentD_) private returns (address safe) {
        require(O.isDAO(parentD_), "Not a DAO to create subdao");
        safe = O.createSubDAO(uint160(parentD_), parentD_);
    }

    function testCreatesSafe() public returns (bool) {
        /// @dev this test requires a forked environment that has a safe factory
        if (SafeFactoryAddresses.factoryAddressForChainId(block.chainid) == address(0)) return false;

        vm.startPrank(Agent1);
        ISafe safeEndpoint = ISafe(_createSafeEndpointFor(address(DAO)));
        uint256 u1 = iMR.howManyTotal(uint160(bytes20(address(DAO))));
        uint256 u2 = iMR.howManyMembers(address(DAO));
        assertTrue(u1 == u2);

        uint256 A1T1 = internalT.balanceOf(Agent1);
        uint256 safeBT1 = internalT.balanceOf(address(safeEndpoint));
        address[] memory links = O.getLinksOf(address(DAO));
        assertTrue(links[links.length - 1] == address(safeEndpoint));

        DAO.signalInflation(122);

        uint256[] memory distris = new uint256[](links.length);
        distris[links.length - 1] = 100;
        vm.warp(block.timestamp + 200);
        assertTrue(DAO.baseInflationRate() > 0);
        uint256 i = DAO.distributiveSignal(distris);
        assertTrue(i == links.length);
        assertTrue(internalT.balanceOf(address(safeEndpoint)) == 0);
        vm.warp(block.timestamp + 100);

        u1 = DAO.redistributeSubDAO(address(safeEndpoint));
        u2 = IDAO20(DAO.internalTokenAddress()).balanceOf(address(safeEndpoint));
        assertTrue(u2 > 0);
        u1 = IERC20(DAO.baseTokenAddress()).balanceOf(address(safeEndpoint));
        vm.stopPrank();
        vm.startPrank(address(safeEndpoint));
        IDAO20(DAO.internalTokenAddress()).unwrapBurn(u2);
        assertTrue(u1 < IERC20(DAO.baseTokenAddress()).balanceOf(address(safeEndpoint)), "expected additional balance");
        assertTrue(u2 > IERC20(DAO.baseTokenAddress()).balanceOf(address(safeEndpoint)), "expected additional balance");

        vm.stopPrank();
    }
}
