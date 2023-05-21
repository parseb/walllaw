// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../src/Member1155.sol";
// import "../src/AbstractAccount.sol";

import "forge-std/Script.sol";
import "test/mocks/M202.sol";
import "test/mocks/mockERC20.sol";
import "test/mocks/M721.sol";

// import "../test/utils/functionality.t.sol";
import "../src/interfaces/IMember1155.sol";
import "../src/interfaces/iInstanceDAO.sol";
import "../src/interfaces/IDAO20.sol";
import "../src/interfaces/IMembrane.sol";
import "../src/interfaces/ILongCall.sol";

contract LocalDeploy is Script {
    M20 Mock20;
    M202 Mock202;
    M721222 M721;
    MemberRegistry M;
    IoDAO O;
    iInstanceDAO instance;
    IMembrane MembraneR;
    ITokenFactory ITF;

    address agent1;
    address agent2;
    address agent3;
    address agent4;

    function setUp() public {
        agent1 = 0xb3F204a5F3dabef6bE51015fD57E307080Db6498;
        agent2 = 0x99B8F1c493B3FD5712Be90b699C1813b51E7B33A;
        agent3 = 0x123984fcA327e93968E0650E07658C618c2EDa74;
        agent4 = 0x4a3e9E61C2090047E60D2C18BaE7c596D9119F10;
    }

    // Block Number: 1
    // Block Hash: 0x19de45fcd7fc1ea9400f02f091b5e5bc213e5c60d6ef0db223d7c3032590c406
    // Block Time: "Tue, 27 Dec 2022 17:15:52 +0000"    bytes32("l0l.wAllAw.l0l")    /// metadata membrane bafybeidl3kccemfn5qmk57xbw5rl7j5szuvzvfasigkvz2d7wapduuyh2y

    function _createBasicMembrane() public returns (uint256 basicMid) {
        address[] memory tokens_ = new address[](1);
        uint256[] memory balances_ = new uint[](1);

        tokens_[0] = address(Mock20);
        balances_[0] = uint256(1000);
        basicMid =
            MembraneR.createMembrane(tokens_, balances_, "bafybeidl3kccemfn5qmk57xbw5rl7j5szuvzvfasigkvz2d7wapduuyh2y");
    }

    function _createSubDaos(uint256 howMany_, address parentDAO_) private returns (address[] memory subDs) {
        uint256 basicMembrane = _createBasicMembrane();
        uint256 i;
        for (i; i < howMany_;) {
            O.createSubDAO(basicMembrane, parentDAO_);
            unchecked {
                ++i;
            }
        }

        subDs = ITF.getDAOsOfToken(iInstanceDAO(parentDAO_).internalTokenAddress());
    }

    function _createNestedDAOs(address startDAO_, uint256 membrane, uint256 levels_)
        public
        returns (address[] memory nestedBaseIs0)
    {
        uint256 i;
        nestedBaseIs0 = new address[](levels_);
        nestedBaseIs0[i] = startDAO_;

        // assertTrue(M.balanceOf(, iInstanceDAO(nestedBaseIs0[i]).baseID()) > 0, "not member");
        membrane = membrane == 0 ? _createBasicMembrane() : membrane;

        i = 1;
        for (i; i < levels_;) {
            nestedBaseIs0[i] = O.createSubDAO(membrane, nestedBaseIs0[i - 1]);
            unchecked {
                ++i;
            }
        }
    }

    function run() public {
        vm.startBroadcast(vm.envUint("GOERLI_PVK"));
        M = new MemberRegistry();
        ITF = ITokenFactory(M.DAO20FactoryAddress());

        Mock20 = new M20();
        Mock202 = new M202();

        O = IoDAO(M.ODAOaddress());
        MembraneR = IMembrane(M.MembraneRegistryAddress());

        M721 = new M721222();

        O.createDAO(address(Mock202));
        address baseDAO = O.createDAO(address(Mock20));

        O.createDAO(address(Mock20));

        address[] memory tokens_ = new address[](1);
        uint256[] memory balances_ = new uint[](1);

        tokens_[0] = address(Mock20);
        balances_[0] = uint256(1000);
        uint256 basicMembraneID =
            MembraneR.createMembrane(tokens_, balances_, "bafybeidl3kccemfn5qmk57xbw5rl7j5szuvzvfasigkvz2d7wapduuyh2y");
        vm.stopBroadcast();

        vm.startBroadcast(vm.envUint("GOERLI_PVK")); 
        iInstanceDAO(baseDAO).mintMembershipToken(agent2);
        iInstanceDAO(baseDAO).signalInflation(50);
        iInstanceDAO(baseDAO).mintMembershipToken(agent3);
        iInstanceDAO(baseDAO).mintMembershipToken(agent4);

        IERC20(iInstanceDAO(baseDAO).baseTokenAddress()).approve(
            iInstanceDAO(baseDAO).internalTokenAddress(), type(uint256).max
        );
        IDAO20(iInstanceDAO(baseDAO).internalTokenAddress()).wrapMint(10 ether);

        _createNestedDAOs(baseDAO, 0, 3);

        address[] memory subdaoAddresses = _createSubDaos(3, baseDAO);

        IERC20(iInstanceDAO(subdaoAddresses[0]).baseTokenAddress()).approve(
            iInstanceDAO(subdaoAddresses[0]).internalTokenAddress(), type(uint256).max
        );
        IDAO20(iInstanceDAO(subdaoAddresses[0]).internalTokenAddress()).wrapMint(2 * 1 ether);

        IERC20(iInstanceDAO(subdaoAddresses[1]).baseTokenAddress()).approve(
            iInstanceDAO(subdaoAddresses[1]).internalTokenAddress(), type(uint256).max
        );
        IDAO20(iInstanceDAO(subdaoAddresses[1]).internalTokenAddress()).wrapMint(2 * 1 ether);

        IERC20(iInstanceDAO(subdaoAddresses[2]).baseTokenAddress()).approve(
            iInstanceDAO(subdaoAddresses[2]).internalTokenAddress(), type(uint256).max
        );
        IDAO20(iInstanceDAO(subdaoAddresses[2]).internalTokenAddress()).wrapMint(3 * 1 ether);

        iInstanceDAO(subdaoAddresses[0]).signalInflation(9);
        iInstanceDAO(subdaoAddresses[1]).signalInflation(90);
        iInstanceDAO(subdaoAddresses[2]).signalInflation(33);

        address[] memory subD2s = _createSubDaos(2, subdaoAddresses[1]);
        address[] memory subD35s = _createSubDaos(5, subD2s[1]);
        _createSubDaos(2, subD35s[1]);
        _createSubDaos(7, subD35s[2]);
        _createSubDaos(3, subD35s[3]);

        iInstanceDAO(subD35s[1]).mintMembershipToken(agent2);
        // iInstanceDAO(subD35s[1]).mintMembershipToken(agent1);
        iInstanceDAO(subD35s[2]).mintMembershipToken(agent3);
        iInstanceDAO(subD35s[3]).mintMembershipToken(agent4);

        address safe1 = O.createSubDAO(uint160(baseDAO), baseDAO);

        address safe2 = O.createSubDAO(uint160(subdaoAddresses[1]), subdaoAddresses[1]);

        vm.stopBroadcast();



        console.log("safes: base - sub1 ______________####_____ : ", safe1, "||", safe2);
        console.log("BASE DAO instance ______________####_____ : ", address(baseDAO));
        console.log("MemberR ADDRESS OS ______________####_____ : ", address(M));
        console.log("ODAO ADDRESS OS ______________####_____ : ", M.ODAOaddress());
        console.log("MembraneR ADDRESS OS ______________####_____ : ", M.MembraneRegistryAddress());
        console.log("____________--- mocks --- _______");
        console.log("M20 ADDRESS OS ______________####_____ : ", address(Mock20));
        console.log("M202 ADDRESS OS ______________####_____ : ", address(Mock202));
        console.log("M721 ADDRESS OS ______________####_____ : ", address(M721));
    }

// == Logs ==
//   safes: base - sub1 ______________####_____ :  0xb96A734adE012DA6E963fE91375806568B296183 || 0x18d0b856a26e484AD7D5A3A339845855Eef0D37d
//   BASE DAO instance ______________####_____ :  0xb47A085DB6e8b7A90ECAC071dD5c727b0d43440f
//   MemberR ADDRESS OS ______________####_____ :  0xFf6d5B4C418A4064aA9aF61Ac97CeA07d833d3e9
//   ODAO ADDRESS OS ______________####_____ :  0x889ba29Fd7990D240Ab38E6f3466c4F4873aC8E9
//   MembraneR ADDRESS OS ______________####_____ :  0x4A13BBe848955f7768AC32B2868B3a5A9f351Cc0
//   ____________--- mocks --- _______
//   M20 ADDRESS OS ______________####_____ :  0x935658841d35A0272A45ADDA854d8b1bDEE1B97e
//   M202 ADDRESS OS ______________####_____ :  0x9d5F9f507E02a6B1b949192F3fD0340Cbd0971CB
//   M721 ADDRESS OS ______________####_____ :  0x9D4722d668C4b790ab670c229c336389056615cb

}
