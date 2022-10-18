// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMemberRegistry {
    function makeMember(address from, address who_, uint256 id_) external returns (bool);
}
