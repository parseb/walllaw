// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../src/Member1155.sol";

import "forge-std/Script.sol";

import "test/mocks/M721.sol";

// import "../test/utils/functionality.t.sol";
import "../src/interfaces/IMember1155.sol";
import "../src/interfaces/iInstanceDAO.sol";
import "../src/interfaces/IDAO20.sol";
import "../src/interfaces/IMembrane.sol";
import "../src/interfaces/ILongCall.sol";
import "../src/interfaces/IAbstract.sol";
import "openzeppelin-contracts/token/ERC721/IERC721.sol";

// == Logs ==
//   Member --- 10200 __________####_____ : 0xc13a47f85854341abb7a08827fb82f6361621d1f
//   ODAO --- 10200 __________####_____ : 0x0893f67758bcff6e0e3871e9c89477fc59d1c2c2
//   memBRAINE --- 10200 __________####_____ : 0xfbdadca21e6281bf79eab915f7513091b3dc3bf3
//   Abstract A --- 10200 __________####_____ : 0x9934c8c8f20c2f3064021bb03e3528599541ea88
//   Meeting POAP --- 10200 __________####_____ : 0xddd82edc6a5532137513ca875aab7527f120b21b
//   ----------populate-----------
//   -----------------------------
//   changing membrane 150460078887702268  --- expected ---  150460078887702268
//   Garden DAO --- 10200 __________####_____ : 0x6fe1c875b0574cc4aa54fa06c538948dd1efce21
//   Membrane ID --- 10200 __________####_____ : 150460078887702268
//   Garden DAO --- 10200 __________####_____ : 0x6fe1c875b0574cc4aa54fa06c538948dd1efce21
//   Internal Token  --- 10200 __________####_____ : 0x44df0a204e0f2882ce647fe4561eb4503bd12493

// http://guild.xyz/walllaw
// LinkeGaard.eth
// Linkebeek community garden incorporated project. Come talk to us every Sunday morning from 9:00 to 13:00 at our on-site stall on Groen Straße nr 306. Simple membership gives access to our garden premises as well as our planning and execution resources.// http://explorer.walllaw.xyz/LinkeGaard.eth
/// {"workspace":{"description":"this is where we budget things","link":"http://linktoprojectedneedsandreviews.com"}, "governance":{"description":"this is where we talk about things", "link":"http://www.discord.com"}}

/// 0xea998a093493c1f0a9f0f0e19c2e54d0f422578c --- instance

/// membrane 455943847601312652  QmdEwTWpsMcBsgJGCAM1eULstRYwSz3inepytgpHwqXSAk

contract ChiadoDeploy is Script {
    MemberRegistry M;
    IoDAO O;
    iInstanceDAO instance;
    IMembrane MembraneR;

    IERC721 CommunityMeetingPoap;

    function run() public {
        vm.startBroadcast(vm.envUint("chiado_PVK")); //// start 1

        M = new MemberRegistry();
        // Mock20 = new M20();
        // Mock202 = new M202();
        O = IoDAO(M.ODAOaddress());
        MembraneR = IMembrane(M.MembraneRegistryAddress());
        CommunityMeetingPoap = IERC721(address(new M721222()));

        string memory addrM = Strings.toHexString(uint256(uint160(address(M))), 20);
        string memory addrODAO = Strings.toHexString(uint256(uint160(address(M.ODAOaddress()))), 20);
        string memory addrMembrane = Strings.toHexString(uint256(uint160(address(M.MembraneRegistryAddress()))), 20);
        string memory addrAbstract = Strings.toHexString(uint256(uint160(address(M.AbstractAddr()))), 20);
        string memory MeetingPoap = Strings.toHexString(uint256(uint160(address(CommunityMeetingPoap))), 20);

        string memory chainID = Strings.toString(block.chainid);

        console.log(string.concat("Member --- ", chainID, " __________####_____ : ", addrM));
        console.log(string.concat("ODAO --- ", chainID, " __________####_____ : ", addrODAO));
        console.log(string.concat("memBRAINE --- ", chainID, " __________####_____ : ", addrMembrane));
        console.log(string.concat("Abstract A --- ", chainID, " __________####_____ : ", addrAbstract));
        console.log(string.concat("Meeting POAP --- ", chainID, " __________####_____ : ", MeetingPoap));

        ////// Populate
        console.log("----------populate-----------");
        console.log("-----------------------------");

        address DAO = O.createDAO(0xb106ed7587365a16b6691a3D4B2A734f4E8268a2);

        address[] memory tokens = new address[](2);
        tokens[0] = iInstanceDAO(DAO).internalTokenAddress();
        /// eur
        tokens[1] = address(CommunityMeetingPoap);

        uint256[] memory balances = new uint256[](2);
        balances[0] = 75 ether;
        balances[1] = 1;

        string memory meta = "QmdEwTWpsMcBsgJGCAM1eULstRYwSz3inepytgpHwqXSAk";

        uint256 membraneId = MembraneR.createMembrane(tokens, balances, meta);

        uint256 result = iInstanceDAO(DAO).changeMembrane(membraneId);
        console.log("changing membrane", Strings.toString(membraneId), " --- expected --- ", Strings.toString(result));

        console.log(
            string.concat(
                "Garden DAO --- ", chainID, " __________####_____ : ", Strings.toHexString(uint256(uint160(DAO)), 20)
            )
        );
        console.log(string.concat("Membrane ID --- ", chainID, " __________####_____ : ", Strings.toString(membraneId)));
        console.log(
            string.concat(
                "Garden DAO --- ", chainID, " __________####_____ : ", Strings.toHexString(uint256(uint160(DAO)), 20)
            )
        );
        console.log(
            string.concat(
                "Internal Token  --- ",
                chainID,
                " __________####_____ : ",
                Strings.toHexString(uint256(uint160(iInstanceDAO(DAO).internalTokenAddress())), 20)
            )
        );
    }
}
