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

// == Logs == Chiado local
//   Member --- 10200 __________####_____ : 0x06ea1e3ce4a2cf4f0b4e699fe65110713e889e12
//   ODAO --- 10200 __________####_____ : 0xbaab6f430a9bf6618724ee64738352a9e19aba60
//   memBRAINE --- 10200 __________####_____ : 0x26f7943b15be7952d8551e644c8fdaf396925add
//   Abstract A --- 10200 __________####_____ : 0xbc75be629709c80c79dceab1c5dd4134f5e17836
//   Meeting POAP --- 10200 __________####_____ : 0x3e356ea26bff02b930d07bab216edfeb3b82cd8b
//   ----------populate-----------
//   -----------------------------
//   changing membrane 507988496082309901  --- expected ---  507988496082309901
//   Garden DAO --- 10200 __________####_____ : 0x5290b2bf41ced96b0a08b51748dd821b2cf005f9
//   Membrane ID --- 10200 __________####_____ : 507988496082309901
//   Garden DAO --- 10200 __________####_____ : 0x5290b2bf41ced96b0a08b51748dd821b2cf005f9
//   Internal Token  --- 10200 __________####_____ : 0xa374b2232e5ee5f92e32485c1e7dc0c5e068925e

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
        tokens[0] = 0xb106ed7587365a16b6691a3D4B2A734f4E8268a2;
        /// eur
        tokens[1] = address(CommunityMeetingPoap);

        uint256[] memory balances = new uint256[](2);
        balances[0] = 75;
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
