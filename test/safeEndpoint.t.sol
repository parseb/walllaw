// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import "../src/interfaces/IMember1155.sol";
import "../src/interfaces/iInstanceDAO.sol";
import "../src/interfaces/IDAO20.sol";
import "../src/interfaces/IERC721.sol";

import "../src/oDAO.sol";
import "../src/Member1155.sol";
import "./mocks/mockERC20.sol";

contract SafeEndpoint is Test {}