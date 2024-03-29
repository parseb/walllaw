// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IMember1155.sol";

interface IoDAO {
    function isDAO(address toCheck) external view returns (bool);

    function createDAO(address BaseTokenAddress_) external returns (address newDAO);

    function createSubDAO(uint256 membraneID_, address parentDAO_) external returns (address subDAOaddr);

    function getParentDAO(address child_) external view returns (address);

    function getDAOsOfToken(address parentToken) external view returns (address[] memory);

    function getDAOfromID(uint256 id_) external view returns (address);

    function getTrickleDownPath(address floor_) external view returns (address[] memory);

    function DAO20FactoryAddr() external view returns (address);

    function getLinksOf(address instanceOrToken_) external view returns (address[] memory);

    function getInitAt(address forAddress) external view returns (uint256);
}
