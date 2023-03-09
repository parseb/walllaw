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
// import {Address} from "openzeppelin-contracts/utils/Address.sol";

// == Logs ==
//   Member --- 10200 ______________####_____ : 0xf9a23a0577da9557aa158faebcd9807d54cd80de
//   ODAO --- 10200 ______________####_____ : 0x2277ff919053beb8ab3f9b4d9397895976af31cb
//   memBRAINE --- 10200 ______________####_____ : 0xdbeda650d780a4f9bdac7c0ad75f957a90296df2
//   Abstract A --- 10200 ______________####_____ : 0xf56d4b2da876b95367194bdb52c5b2f14ac68116

/// eEUR 0x861B1cD2CCBd27e8Ac0262a99227430791D27c3A 75
/// garden poap 0x861B1cD2CCBd27e8Ac0262a99227430791D27c3A

// http://guild.xyz/walllaw
// LinkeGaard.eth
// Linkebeek community garden incorporated project. Come talk to us every Sunday morning from 9:00 to 13:00 at our on-site stall on Groen Straße nr 306. Simple membership gives access to our garden premises as well as our planning and execution resources.// http://explorer.walllaw.xyz/LinkeGaard.eth
/// {"workspace":{"description":"this is where we budget things","link":"http://linktoprojectedneedsandreviews.com"}, "governance":{"description":"this is where we talk about things", "link":"http://www.discord.com"}}

/// 0x6DF41c68Ed20857013B818A27aB589C669cb787E --- instance

/// membrane 53542622975347230  QmdEwTWpsMcBsgJGCAM1eULstRYwSz3inepytgpHwqXSAk

contract LocalDeploy is Script {
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

        console.log(string.concat("Member --- ", chainID, " ______________####_____ : ", addrM));
        console.log(string.concat("ODAO --- ", chainID, " ______________####_____ : ", addrODAO));
        console.log(string.concat("memBRAINE --- ", chainID, " ______________####_____ : ", addrMembrane));
        console.log(string.concat("Abstract A --- ", chainID, " ______________####_____ : ", addrAbstract));
        console.log(string.concat("Abstract A --- ", chainID, " ______________####_____ : ", MeetingPoap));
    }
}
