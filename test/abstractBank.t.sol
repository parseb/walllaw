// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./utils/functionality.t.sol";

contract BankTest is Test, MyUtils {
    
    IAbstract AbstractA;

    //// copied for endpointWithdraw
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

        /// end of copy 

        AbstractA = IAbstract(iMR.AbstractAddr());
    }


    // function depositFor(
    //     address forWho_,
    //     address toWhere_,
    //     uint256 amount_,
    //     string memory transferData_,
    //     bytes memory signature_
    // )

    function testBankMint() public {

        address MojoJoJo = address(123456788099991243666789);
        
        address authorizedAgent = AbstractA.owner();
        IERC20 baseT = IERC20(DAO.baseTokenAddress());
        IERC20 internalT = IERC20(DAO.internalTokenAddress());

        vm.expectRevert();
        vm.prank(MojoJoJo);
        AbstractA.depositFor(Agent2, address(DAO), 1000, "someTransferData", bytes("fsfd") );

        vm.expectRevert();
        vm.prank(authorizedAgent);
        AbstractA.depositFor(Agent2, address(DAO), 1000, "someTransferData", bytes("fsfd") );

        
        
        vm.prank(authorizedAgent);
        baseT.approve(address(AbstractA), type(uint256).max);
        
        uint256 preB = internalT.balanceOf(authorizedAgent);

        vm.prank(authorizedAgent);
        AbstractA.depositFor(Agent2, address(DAO), 1000, "someTransferData", bytes("fsfd") );
        
        uint256 postB = internalT.balanceOf(Agent2);

        //// Result Agent2 has internalT balance as a result of 'Authorized Agent' depositFor action
        assertTrue(preB < postB, 'expected internal token balance');
    }

}