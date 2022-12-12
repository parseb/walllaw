// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./utils/functionality.t.sol";
import "./mocks/mExtern.sol";

contract GravityFeed is Test, MyUtils {
    /// pull and mint inflation from upper to lower

    iInstanceDAO DAO;
    address DDD;

    function setUp() public {
        vm.startPrank(Agent1);

        DDD = _createDAO(address(BaseE20));
        DAO = iInstanceDAO(DDD);

        BaseE20.approve(DAO.internalTokenAddress(), type(uint256).max);
        IDAO20(DAO.internalTokenAddress()).wrapMint(1 ether);
        DAO.mintMembershipToken(Agent1);
        skip(1);
        DAO.signalInflation(10);
        assertTrue(DAO.baseInflationRate() == 10, 'base inflation not set');

        vm.stopPrank();
    }


    function _initNestedConstantRates(
        uint256 howMany,
        /// nr SubDAOS
        uint256 inflationRate,
        /// all use same inflation rate
        uint256 distributionRate,
        /// percentage of inflation for pull down
        uint256 baseWrapAmount,
        /// base DAO capital
        uint256 divTrickleWrap,
        ///  divided by wrapped to lower level
        uint256 skipBetweenSignals
    )
        /// sec time increment between inflation and distri. signal
        public
        returns (iInstanceDAO[] memory DAOS)
    {
        address[] memory nestedDAOS = new address[](howMany);

        vm.startPrank(Agent1, Agent1);
        assertTrue(DAO.isMember(Agent1), "not member of base");

        nestedDAOS = _createNestedDAOs(DDD, 0, howMany);

        uint256[] memory distributionAmts = new uint256[](1);
        distributionAmts[0] = distributionRate;

        BaseE20.approve(address(DAO), 100 ether);
        IDAO20(DAO.internalTokenAddress()).wrapMint(baseWrapAmount);

        DAOS = new iInstanceDAO[](howMany);
        uint256 i;
        uint256 sum;
        for (i; i < nestedDAOS.length; i++) {
            uint256 amtToTrickle = baseWrapAmount / divTrickleWrap;
            DAOS[i] = iInstanceDAO(nestedDAOS[i]);
            IERC20(DAOS[i].baseTokenAddress()).approve(DAOS[i].internalTokenAddress(), amtToTrickle);
            IDAO20(DAOS[i].internalTokenAddress()).wrapMint(amtToTrickle);
            DAOS[i].signalInflation(inflationRate);
            console.log(i);
            if(i < howMany-1) DAOS[i].distributiveSignal(distributionAmts);
            sum += DAOS[i].baseInflationRate();
            if (skipBetweenSignals > 0) skip(skipBetweenSignals);
        }

        require(sum == (howMany * inflationRate));

        vm.stopPrank();
    }


    function _DiferentiatedBalances(uint hM_) public returns (iInstanceDAO[] memory DAOS){

        uint256 timeStart = block.timestamp;

        DAOS = _initNestedConstantRates(hM_, 10, 20, 100 ether, 10, 10 days);
    
        assertTrue(DAOS.length == hM_);
        uint256 timeNow = block.timestamp;
        assertTrue(timeNow == timeStart + (hM_ * 10 days));

        uint i = DAOS.length;

        for (i; i>=2;) {
            iInstanceDAO D =  DAOS[i-1];
            if (D.parentDAO() == address(0)) break;
            if (i > 2) assertTrue(D.parentDAO() == address(DAOS[i-2]));
            
            console.log(address(DAOS[i-1]));

            address[] memory path = new address[](hM_);
            path = O.getTrickleDownPath(address(DAOS[i-1]));

            unchecked { --i;}
        }

    }

    /// @dev fuzz : uint howMany
    uint howMany =12;
    function testDiferentiatedBalances() public {
        // vm.assume(howMany < 99);
        // vm.assume(howMany > 2);
        iInstanceDAO[] memory DsszNuts;
        DsszNuts = _DiferentiatedBalances(howMany);

        address[] memory fullPath = new address[](DsszNuts.length);
        iInstanceDAO lastNut = DsszNuts[DsszNuts.length-1];
        fullPath = O.getTrickleDownPath(address(lastNut));

        assertTrue(fullPath[fullPath.length-1] == address(0), 'chain end is not 0');
        assertTrue(fullPath[0] == lastNut.parentDAO(), 'fist in path is not parent');


        uint256 i=0;
        for (i; i < fullPath.length-2; ) {
            IERC20 baseT = IERC20(iInstanceDAO(fullPath[i+1]).baseTokenAddress());
            IERC20 internalT = IERC20(iInstanceDAO(fullPath[i+1]).internalTokenAddress());
            uint baseBalanceBeforeFeed = baseT.balanceOf(fullPath[i+1]);
            uint internalTBeforeFeed =  internalT.balanceOf(fullPath[i+1]);
            assertTrue(fullPath[i+1] == iInstanceDAO(fullPath[i]).parentDAO(), "expected parent - subdao relations");
            iInstanceDAO(fullPath[i+1]).feedMe();
            skip(10);
            uint baseBalanceAfterFeed = baseT.balanceOf(fullPath[i+1]);
            uint internalTAfterFeed =  internalT.balanceOf(fullPath[i+1]);
            console.log(baseBalanceBeforeFeed);
            console.log(internalTBeforeFeed);
            console.log("------beforeFeed^----afterFeed >");
            console.log(baseBalanceAfterFeed);
            console.log(internalTAfterFeed);

            assertTrue(baseBalanceAfterFeed > baseBalanceBeforeFeed);
            assertTrue(internalTBeforeFeed == internalTAfterFeed);

            unchecked { ++ i;}

        }

    }


}


