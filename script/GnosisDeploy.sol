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

// == Logs == GNOSIS local

// == Logs ==
//   Member --- 100 __________####_____ : 0xa5a0ef557bd8fe585bb3a7843641e5b0ed367399
//   ODAO --- 100 __________####_____ : 0x1737f9e4e620def64fbd8a16e6b286b697dedf56
//   memBRAINE --- 100 __________####_____ : 0x8ccfeb027fd6e343d1f670591f1479f2939409ef
//   Abstract A --- 100 __________####_____ : 0xb67749bd1a5261ecad6fc9528c74de27dff8ea8f
//   Meeting POAP --- 100 __________####_____ : 0x0996bb36c3d0295ca26e66ae891fea1b653d13a8
//   ----------populate-----------
//   -----------------------------
//   changing membrane 858924499513184087  --- expected ---  858924499513184087
//   Garden DAO --- 100 __________####_____ : 0xba6d1d4c18c03c1df58a1e323c93dd4e5bc400b4
//   Membrane ID --- 100 __________####_____ : 858924499513184087
//   Garden DAO --- 100 __________####_____ : 0xba6d1d4c18c03c1df58a1e323c93dd4e5bc400b4
//   Internal Token  --- 100 __________####_____ : 0x6dfd8b24fd1016e4fcf8aa7a222322ee9c27a1e1

// http://guild.xyz/walllaw
// LinkeGaard.eth
// Linkebeek community garden incorporated project. Come talk to us every Sunday morning from 9:00 to 13:00 at our on-site stall on Groen Straße nr 306. Simple membership gives access to our garden premises as well as our planning and execution resources.// http://explorer.walllaw.xyz/LinkeGaard.eth
/// {"workspace":{"description":"this is where we budget things","link":"http://linktoprojectedneedsandreviews.com"}, "governance":{"description":"this is where we talk about things", "link":"http://www.discord.com"}}

/// 0x6DF41c68Ed20857013B818A27aB589C669cb787E --- instance

/// membrane 53542622975347230  QmdEwTWpsMcBsgJGCAM1eULstRYwSz3inepytgpHwqXSAk

contract GnosisDeploy is Script {
    MemberRegistry M;
    IoDAO O;
    iInstanceDAO instance;
    IMembrane MembraneR;

    IERC721 CommunityMeetingPoap;

    function run() public {
        vm.startBroadcast(vm.envUint("gnosis_pvk")); //// start 1

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

        address DAO = O.createDAO(0xcB444e90D8198415266c6a2724b7900fb12FC56E);

        address[] memory tokens = new address[](2);
        tokens[0] = iInstanceDAO(DAO).internalTokenAddress();
        /// eur
        tokens[1] = address(CommunityMeetingPoap);

        uint256[] memory balances = new uint256[](2);
        balances[0] = 1 ether;
    

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
