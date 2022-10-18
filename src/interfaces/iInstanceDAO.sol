// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface iInstanceDAO {
    function entityData(uint256 id) external view returns (bytes memory);
}
