// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IMember1155.sol";

interface IoDAO {
    function isDAO(address toCheck) external view returns (bool);

    function makeMember(address who_, uint256 id_, bytes memory tokenData) external returns (uint256);

    function getMembrane(uint256 id) external view returns (Membrane memory);

    function setMembrane(address DAO_, uint256 membraneID_) external returns (bool);

    function createSubDAO(uint256 membraneID_, address parentDAO_) external returns (address subDAOaddr);

    function createMembrane(address[] memory tokens_, uint256[] memory balances_, bytes memory meta_)
        external
        returns (uint256);

    function inUseMembraneId(address DAOaddress_) external view returns (uint256 Id);

    function getInUseMembraneOfDAO(address DAOAddress_) external view returns (Membrane memory);

    function getParentDAO(address child_) external view returns (address);

    function getDAOsOfToken(address parentToken) external view returns (address[] memory);

    function isMembrane(uint256 id_) external view returns (bool);

    function longDistanceCall(uint256 id) external returns (bool);

    function getLongDistanceCall(uint256 id_) external view returns (ExternallCall memory);

    function prepLongDistanceCall(uint256 id_) external returns (ExternallCall memory);

    function getTrickleDownPath(address floor_) external view returns (address[] memory);
    
}
