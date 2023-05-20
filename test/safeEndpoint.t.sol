// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./utils/functionality.t.sol";

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

    function testCreatesSafe() public {
        // address returnesAddress = SafeFactory.createSafeL2(address(D1d));

        vm.prank(Agent1);
        address safe = O.createSubDAO(uint160(address(DAO)), address(DAO));
        assertTrue(safe != address(0));
        assertTrue(IGSafe(safe).parentAddress() == address(DAO));
    }
}
