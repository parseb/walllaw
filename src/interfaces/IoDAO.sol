// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IMember1155.sol";

interface IoDAO {
    function isDAO(address toCheck) external view returns (bool);

    function makeMember(address who_, uint256 id_, bytes memory tokenData) external returns (uint256);

    function createDAO(address BaseTokenAddress_) external returns (address newDAO);

    function createSubDAO(uint256 membraneID_, address parentDAO_) external returns (address subDAOaddr);

    function getLongDistanceCall(uint256 id_) external view returns (ExternallCall memory);

    function createExternalCall(address callPoint_, bytes memory callData_) external returns (uint256 id);

    function getParentDAO(address child_) external view returns (address);

    function getDAOsOfToken(address parentToken) external view returns (address[] memory);

    function getDAOfromID(uint256 id_) external view returns (address);

    function longDistanceCall(uint256 id) external returns (bool);

    function prepLongDistanceCall(uint256 id_) external returns (ExternallCall memory);

    function getTrickleDownPath(address floor_) external view returns (address[] memory);
}
