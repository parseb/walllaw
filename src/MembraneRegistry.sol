// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IoDAO.sol";
import "./interfaces/iInstanceDAO.sol";
import "./interfaces/IMembrane.sol";
import "./interfaces/IMember1155.sol";

import "openzeppelin-contracts/token/ERC20/IERC20.sol";

import "./errors.sol";

contract MembraneRegistry {
    address MRaddress;
    IMemberRegistry iMR;

    mapping(uint256 => Membrane) getMembraneById;
    mapping(address => uint256) usesMembrane;

    constructor() {
        iMR = IMemberRegistry(msg.sender);
    }

    error membraneNotFound();
    error aDAOnot();

    event CreatedMembrane(uint256 id, bytes metadata);
    event ChangedMembrane(address they, uint256 membrane);

    function createMembrane(address[] memory tokens_, uint256[] memory balances_, bytes memory meta_)
        public
        returns (uint256 id)
    {
        /// @dev consider negative as feature . [] <- isZero. sybil f
        /// @dev @security erc165 check
        Membrane memory M;
        M.tokens = tokens_;
        M.balances = balances_;
        M.meta = meta_;
        id = uint256(keccak256(abi.encode(M)));
        getMembraneById[id] = M;

        emit CreatedMembrane(id, meta_);
    }

    function setMembrane(uint256 membraneID_) external returns (bool) {
        if (getMembraneById[membraneID_].tokens.length == 0) revert membraneNotFound();
        usesMembrane[msg.sender] = membraneID_;
        emit ChangedMembrane(msg.sender, membraneID_);
        return true;
    }

    function checkG(address _custard) public view returns (bool s) {
        Membrane memory M = getInUseMembraneOfDAO(address(this));
        uint256 i;
        s = true;
        for (i; i < M.tokens.length;) {
            s = s && (IERC20(M.tokens[i]).balanceOf(_custard) >= M.balances[i]);
            unchecked {
                ++i;
            }
        }
    }

    function entityData(uint256 id_) external view returns (bytes memory) {
        return getMembraneById[id_].meta;
    }

    function getMembrane(uint256 id_) external view returns (Membrane memory) {
        return getMembraneById[id_];
    }

    function isMembrane(uint256 id_) external view returns (bool) {
        return (getMembraneById[id_].tokens.length > 0);
    }

    function inUseMembraneId(address DAOaddress_) public view returns (uint256 ID) {
        return usesMembrane[DAOaddress_];
    }

    function getInUseMembraneOfDAO(address DAOAddress_) public view returns (Membrane memory) {
        return getMembraneById[usesMembrane[DAOAddress_]];
    }
}
