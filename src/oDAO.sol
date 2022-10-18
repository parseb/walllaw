// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "./Member1155.sol";
import "./DAOinstance.sol";
import "./interfaces/IMember1155.sol";
import "./interfaces/iInstanceDAO.sol";

contract ODAO {
    mapping(uint256 => address) daoOfId;
    mapping(address => address[]) daosOfToken;

    IMemberRegistry MR;

    constructor() {
        MR = IMemberRegistry(address(new MemberRegistry()));
    }

    /*//////////////////////////////////////////////////////////////
                                 errors
    //////////////////////////////////////////////////////////////*/

    error UnregisteredDAO();
    error UnauthorizedID();
    error InvalidMintID();

    /*//////////////////////////////////////////////////////////////
                                 events
    //////////////////////////////////////////////////////////////*/

    event newDAOCreated(address indexed DAO, address indexed token_);
    event isNowMember(address indexed who, uint256 indexed where, address indexed DAO);

    /*//////////////////////////////////////////////////////////////
                                 public
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                                 internal
    //////////////////////////////////////////////////////////////*/

    function createDAO(address BaseTokenAddress_) external returns (address newDAO) {
        newDAO = address(new DAOinstance(BaseTokenAddress_, msg.sender));
        daoOfId[uint160(bytes20(newDAO))] = newDAO;
        daosOfToken[BaseTokenAddress_].push(newDAO);

        emit newDAOCreated(newDAO, BaseTokenAddress_);
    }

    function makeMember(address who_, uint256 id_) external returns (bool) {
        if (!isDAO(msg.sender)) revert UnregisteredDAO();
        if (!(getDAOfromID(id_) == msg.sender)) revert UnauthorizedID();
        if (!(id_ / uint160(bytes20(msg.sender)) == 0)) revert InvalidMintID();

        daoOfId[id_] = msg.sender;

        emit isNowMember(who_, id_, msg.sender);
        return MR.makeMember(msg.sender, who_, id_);
    }

    /*//////////////////////////////////////////////////////////////
                                 VIEW
    //////////////////////////////////////////////////////////////*/

    /// @notice checks if address is a registered DAOS
    /// @dev used to authenticate membership minting
    /// @param toCheck_: address to check if registered as DAO
    function isDAO(address toCheck_) public view returns (bool) {
        return daoOfId[uint160(bytes20(toCheck_))] == toCheck_;
    }

    /// @notice returns the DAO instance to which the given id_ belongs to
    function getDAOfromID(uint256 id_) public view returns (address) {
        return daoOfId[id_];
    }

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
}
