// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IoDAO {

        struct Membrane {
        address[] tokens;
        uint256[] balances;
        bytes meta;
    }
    
    function isDAO(address toCheck) external view returns (bool);

    function makeMember(address who_, uint256 id_, bytes memory tokenData) external returns (uint256);

    function getMembrane(uint id) external view returns (Membrane memory);

}
