// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMembrane {
    struct Membrane {
        address[] tokens;
        uint256[] balances;
        bytes meta;
    }

    function getMembrane(uint256 id) external view returns (Membrane memory);

    function setMembrane(uint256 membraneID_) external returns (bool);

    function inUseMembraneId(address DAOaddress_) external view returns (uint256 Id);

    function getInUseMembraneOfDAO(address DAOAddress_) external view returns (Membrane memory);

    function createMembrane(address[] memory tokens_, uint256[] memory balances_, bytes memory meta_)
        external
        returns (uint256);
    function isMembrane(uint256 id_) external view returns (bool);

    function checkG(address _custard) external view returns (bool s);
}
