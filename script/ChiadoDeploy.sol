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

// == Logs ==
//   Member --- 10200 __________####_____ : 0xc470a5c25478cc22307989507db2c72840d27d30
//   ODAO --- 10200 __________####_____ : 0x0290582268285385594602db7920b41791ad4ac5
//   memBRAINE --- 10200 __________####_____ : 0x92ba025f07f9a718c02e96de86038c77684b8963
//   Abstract A --- 10200 __________####_____ : 0x7c69256d4065cd1192f54179122c0ff34dc297a5
//   Meeting POAP --- 10200 __________####_____ : 0x3166d537ab6f9b9ec4212c7016613a9ba195d3ec
//   ----------populate-----------
//   -----------------------------
//   changing membrane 792264664476404556  --- expected ---  792264664476404556
//   Base Internal Token --- 10200 __________####_____ : 0xb8bd69d8b1853a16f2a59167a0f977d63effd7ee
//   Garden DAO --- 10200 __________####_____ : 0x98cf5227f4bd82ceee89d4528695dce5e726ad48
//   Membrane ID --- 10200 __________####_____ : 792264664476404556
//   Garden DAO --- 10200 __________####_____ : 0x98cf5227f4bd82ceee89d4528695dce5e726ad48
//   Internal Token  --- 10200 __________####_____ : 0xb8bd69d8b1853a16f2a59167a0f977d63effd7ee
//   new office project Membraneid 792264664476404556 361672278035523907
//   new SUBD office project 0x169daeb538b6a3b696e8e4b353bb18d40e97355a

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
                "Base Internal Token --- ",
                chainID,
                " __________####_____ : ",
                Strings.toHexString(uint256(uint160(iInstanceDAO(DAO).internalTokenAddress())))
            )
        );

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

        ///// new membrane and subdao

        address[] memory tokens2 = new address[](1);
        tokens[0] = iInstanceDAO(DAO).internalTokenAddress();

        uint256[] memory balances2 = new uint256[](1);
        balances[0] = 500 ether;

        uint256 Membraneid = MembraneR.createMembrane(tokens2, balances2, meta);
        console.log("new office project Membraneid", Strings.toString(membraneId), Strings.toString(Membraneid));

        address subD = O.createSubDAO(Membraneid, address(DAO));

        console.log("new SUBD office project", Strings.toHexString(uint256(uint160((subD)))));
    }
}
