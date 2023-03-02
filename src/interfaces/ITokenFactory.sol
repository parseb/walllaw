// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;


interface ITokenFactory {

    /// @notice creates internal token of type DAO20 with declared base for sender
    function makeForMe(address DeclaredBase_) external returns (address);


    ///// View

    /// @dev should attempt to trickle to base if not found
    /// @notice returns base value setlement token given the address of a DAO
    function getBaseOf(address) external returns (address);

    /// @notice an ERC20 token can have an unlimited number of DAOs. This returns all root DAOs in existence for provided ERC20.
    /// @param parentToken ERC20 contract address
    function getDAOsOfToken(address parentToken) external view returns (address[] memory);
    
    function getOwner() external returns (address);

    function setODAO(address ODAO_) external;

}