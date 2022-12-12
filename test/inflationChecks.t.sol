// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./utils/functionality.t.sol";

contract CheckTrickle is Test, MyUtils {
    iInstanceDAO DAO;

    function setUp() public {
        DAO = iInstanceDAO(_createDAO(address(BaseE20)));
        uint256 membrane = _createBasicMembrane();
        // _createSubDaos();
    }

    function _writeToTestLog(string memory line_) internal {
        string memory path = vm.readFile("logPath.txt");
        vm.writeFile(path, line_);
    }

    function testDistributionIsConstant() public {
        _writeToTestLog("-------- begin fuzz -------");
    }
}
