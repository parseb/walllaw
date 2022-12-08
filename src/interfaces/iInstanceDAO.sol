// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface iInstanceDAO {
    function entityData(uint256 id) external view returns (bytes memory);

    function giveOwnership() external returns (address);

    function wrapMint(uint256 amount) external returns (bool);

    function unwrapBurn(uint256 amount_) external returns (bool);

    function incrementSubDAO() external returns (uint256);

    function signalInflation(uint256 percentagePerYear_) external returns (uint256 inflationRate);

    /// view

    function owner() external view returns (address);

    function internalTokenAddr() external view returns (address);

    function baseTokenAddress() external view returns (address);

    function baseID() external view returns (uint256);

    function localID() external view returns (uint256);

    function mintMembershipToken(address to_) external returns (bool);
    /// only owner & majority
    function setPerSecondInterestRate(uint256 ratePerSec) external returns (bool);

    function changeMembrane(uint256 membraneId_) external returns (uint256 membraneID);

    function giveOwnership(address newOwner_) external returns (address);

    function instantiatedAt() external returns (uint256);

    function gCheck(address who_) external returns (bool);

    function makeOwnerMemberOnCreateForEndpointFunctionality() external returns (bool);

    function getUserReDistribution(address ofWhom) external view returns (uint256[] memory);

    function initiatedAt() external view returns (uint256);

    function baseInflationRate() external view returns (uint256);

    function baseInflationPerSec() external view returns (uint256);

    function checkG(address) external view returns (bool);

    function multicall(bytes[] memory) external returns (bytes[] memory results);

    function executeExternalLogic(uint256 callId_) external returns (bool);
}
