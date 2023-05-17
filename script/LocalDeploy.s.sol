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
        agent1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        agent2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        agent3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
        agent4 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    }

    // Transaction: 0x739e031c195face8ba4a33d61e042ab3756e9d39930a0e2fa659283c38fde2e8
    // Contract created: 0x5b97542891ca4c71112865cacfee6a4361c913a6
    // Gas used: 8089117

    // Transaction: 0x072890a03a08a3f6d9e92a0ae05e9030d0e751f77cd8ee822042870dab41495b
    // Contract created: 0x5b3e74dc6a9f8b571aac029b9db4b11aecb9af08
    // Gas used: 1170349

    // Transaction: 0x882c184978a4553184d8441210c8f4a25f1c9cf5a9cbb5d9b48ef601a5398d05
    // Contract created: 0x863200822a97038394c7d1803b4562dc014dd862
    // Gas used: 1170349

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
        vm.startBroadcast(vm.envUint("ANVIL_2")); //// start 1

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
        vm.stopBroadcast(); //// stop 1

        vm.startBroadcast(vm.envUint("ANVIL_2")); //// start 2

        // iInstanceDAO(baseDAO).mintMembershipToken(agent2);
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

        // iInstanceDAO(subD35s[1]).mintMembershipToken(agent2);
        iInstanceDAO(subD35s[2]).mintMembershipToken(agent3);
        iInstanceDAO(subD35s[3]).mintMembershipToken(agent4);

        vm.stopBroadcast(); //// stop 2

        vm.startBroadcast(vm.envUint("ANVIL_3"));

        IERC20(iInstanceDAO(baseDAO).baseTokenAddress()).approve(
            iInstanceDAO(baseDAO).internalTokenAddress(), type(uint256).max
        );
        IDAO20(iInstanceDAO(baseDAO).internalTokenAddress()).wrapMint(10 ether);

        // iInstanceDAO(subdaoAddresses[0]).mintMembershipToken(agent2);
        iInstanceDAO(subdaoAddresses[1]).mintMembershipToken(agent3);
        iInstanceDAO(subdaoAddresses[2]).mintMembershipToken(agent4);

        IERC20(iInstanceDAO(subdaoAddresses[0]).baseTokenAddress()).approve(
            iInstanceDAO(subdaoAddresses[0]).internalTokenAddress(), type(uint256).max
        );
        IDAO20(iInstanceDAO(subdaoAddresses[0]).internalTokenAddress()).wrapMint(3 * 1 ether);

        IERC20(iInstanceDAO(subdaoAddresses[1]).baseTokenAddress()).approve(
            iInstanceDAO(subdaoAddresses[1]).internalTokenAddress(), type(uint256).max
        );
        IDAO20(iInstanceDAO(subdaoAddresses[1]).internalTokenAddress()).wrapMint(3 * 1 ether);

        IERC20(iInstanceDAO(subdaoAddresses[2]).baseTokenAddress()).approve(
            iInstanceDAO(subdaoAddresses[2]).internalTokenAddress(), type(uint256).max
        );
        IDAO20(iInstanceDAO(subdaoAddresses[2]).internalTokenAddress()).wrapMint(2 * 1 ether);

        vm.stopBroadcast();

        console.log("BASE DAO instance ______________####_____ : ", address(baseDAO));
        console.log("MemberR ADDRESS OS ______________####_____ : ", address(M));
        console.log("ODAO ADDRESS OS ______________####_____ : ", M.ODAOaddress());
        console.log("MembraneR ADDRESS OS ______________####_____ : ", M.MembraneRegistryAddress());
        console.log("____________--- mocks --- _______");
        console.log("M20 ADDRESS OS ______________####_____ : ", address(Mock20));
        console.log("M202 ADDRESS OS ______________####_____ : ", address(Mock202));
        console.log("M721 ADDRESS OS ______________####_____ : ", address(M721));
    }
}
