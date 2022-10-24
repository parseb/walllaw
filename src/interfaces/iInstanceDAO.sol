// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface iInstanceDAO {
    function entityData(uint256 id) external view returns (bytes memory);

    function giveOwnership() external returns (address);

    function wrapMint(uint256 amount) external returns(bool);

    function unwrapBurn(uint256 amount_) external returns (bool);

    function incrementSubDAO() external returns (uint);

    /// view

    function owner() external view returns (address);
    
    function internalTokenAddr() external view returns (address);

    function baseTokenAddress() external view returns (address);

    function baseID() external view returns (uint);

    function localID() external view returns (uint);

    function mintMembershipToken(address to_) external returns (bool);
    /// only owner
    function setPerSecondInterestRate(uint256 ratePerSec) external returns (bool);

    function giveOwnership(address newOwner_) external returns (address);



}
