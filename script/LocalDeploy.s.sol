// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Member1155.sol";

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

    function setUp() public {}

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
    // Block Time: "Tue, 27 Dec 2022 17:15:52 +0000"

    function _createBasicMembrane() public returns (uint256 basicMid) {
        address[] memory tokens_ = new address[](1);
        uint256[] memory balances_ = new uint[](1);

        tokens_[0] = address(Mock20);
        balances_[0] = uint256(1000);
        basicMid = MembraneR.createMembrane(tokens_, balances_, bytes("QmddchiYMQGZYLZf86jhyhkxRqrGfpBNr53b4oiV76q6aq"));
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

        subDs = O.getDAOsOfToken(iInstanceDAO(parentDAO_).internalTokenAddress());
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
        vm.startBroadcast(vm.envUint("ANVIL_1"));
        M = new MemberRegistry();
        Mock20 = new M20();
        Mock202 = new M202();
        O = IoDAO(M.ODAOaddress());
        MembraneR = IMembrane(M.MembraneRegistryAddress());
        M721 = new M721222();
        vm.stopBroadcast();

        vm.startBroadcast(vm.envUint("ANVIL_2"));
        address baseDAO = O.createDAO(address(Mock202));

        address[] memory tokens_ = new address[](1);
        uint256[] memory balances_ = new uint[](1);

        tokens_[0] = address(Mock20);
        balances_[0] = uint256(1000);
        uint256 basicMembraneID =
            MembraneR.createMembrane(tokens_, balances_, bytes("QmddchiYMQGZYLZf86jhyhkxRqrGfpBNr53b4oiV76q6aq"));

        iInstanceDAO(baseDAO).mintMembershipToken(0x5457d92f47212E9287c1A1c31e708f574ab66125);
        iInstanceDAO(baseDAO).signalInflation(50);

        iInstanceDAO(baseDAO).mintMembershipToken(0x323525cB37428d72e33B8a3d9a72F848d08Bf2B7);
        iInstanceDAO(baseDAO).mintMembershipToken(0x5df6cF21815ca55057bb5cA159A3130c193bb0a1);

        _createNestedDAOs(baseDAO, basicMembraneID, 3);

        vm.stopBroadcast();
    }
}
