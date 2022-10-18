// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IoDAO {
    function isDAO(address toCheck) external view returns (bool);

    function makeMember(address who_, uint256 id_, bytes memory tokenData) external returns (uint256);
}
