// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./DAOinstance.sol";
import "./interfaces/IMember1155.sol";
import "./interfaces/iInstanceDAO.sol";
import "./interfaces/IoDAO.sol";
import "./interfaces/ITokenFactory.sol";

import "./DAO20.sol";

contract DAO20Factory is ITokenFactory {
    address currentOwner;
    IoDAO ODAO;

    //// @notice what DAO entitties use specified token as base.
    mapping(address => address[]) daosOfToken;

    constructor() {}

    error Busy();
    error AlreadyDone();

    event MadeInternal20(address base, address owner, address newToken);

    function makeForMe(address DeclaredBase_) external returns (address newDAO20) {
        if (currentOwner != address(0)) revert Busy();
        currentOwner = msg.sender;
        newDAO20 = address(new DAO20(DeclaredBase_, "WalllaW Instance", "WWdo", 18));
        daosOfToken[DeclaredBase_].push(msg.sender);
        delete currentOwner;

        emit MadeInternal20(DeclaredBase_, msg.sender, newDAO20);
    }

    /// @notice an ERC20 token can have an unlimited number of DAOs. This returns all root DAOs in existence for provided ERC20.
    /// @param parentToken ERC20 contract address
    function getDAOsOfToken(address parentToken) external view returns (address[] memory) {
        return daosOfToken[parentToken];
    }

    function getOwner() external view returns (address) {
        return currentOwner;
    }

    /// notice gets the root base on which the top value of provided address is constructed.
    function getBaseOf(address DAOaddress_) external view returns (address valueBase) {
        address[] memory tricklePath = ODAO.getTrickleDownPath(DAOaddress_);
        valueBase = tricklePath.length == 0
            ? iInstanceDAO(valueBase).baseTokenAddress()
            : iInstanceDAO(tricklePath[0]).baseTokenAddress();
    }

    function setODAO(address ODAO_) external {
        if (address(ODAO) != address(0)) revert AlreadyDone();
        ODAO = IoDAO(ODAO_);
    }

    function ODAOaddress() external view returns (address) {
        return address(ODAO);
    }
}
