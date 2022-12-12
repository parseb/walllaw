// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface iInstanceDAO {
    function __initSetParentAddress(address parent_) external;

    function giveOwnership() external returns (address);

    function unwrapBurn(uint256 amount_) external returns (bool);

    function incrementSubDAO() external returns (uint256);

    function signalInflation(uint256 percentagePerYear_) external returns (uint256 inflationRate);

    function mintMembershipToken(address to_) external returns (bool);

    function changeMembrane(uint256 membraneId_) external returns (uint256 membraneID);

    function distributiveSignal(uint256[] memory cronoOrderedDistributionAmts) external returns (uint256);

    function multicall(bytes[] memory) external returns (bytes[] memory results);

    function executeExternalLogic(uint256 callId_) external returns (bool);

    function feedMe() external returns (uint256);

    function redistributeSubDAO(address subDAO_) external returns (uint256);
    /// view

    function owner() external view returns (address);

    function internalTokenAddress() external view returns (address);

    function baseTokenAddress() external view returns (address);

    function baseID() external view returns (uint256);

    function localID() external view returns (uint256);

    function giveOwnership(address newOwner_) external returns (address);

    function instantiatedAt() external returns (uint256);

    function gCheck(address who_) external returns (bool);

    function memberOnCreate() external returns (bool);

    function getUserReDistribution(address ofWhom) external view returns (uint256[] memory);

    function initiatedAt() external view returns (uint256);

    function baseInflationRate() external view returns (uint256);

    function baseInflationPerSec() external view returns (uint256);

    function checkG(address) external view returns (bool);

    function feedStart() external returns (uint256 minted);

    function isMember(address who_) external view returns (bool);

    function parentDAO() external view returns (address);

    function mintInflation() external returns (uint256);
}
