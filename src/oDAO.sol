// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "./Member1155.sol";
import "./DAOinstance.sol";
import "./interfaces/IMember1155.sol";
import "./interfaces/iInstanceDAO.sol";


contract ODAO {
    mapping(uint256 => address) daoOfId;
    mapping (address => address[]) daosOfToken;
    mapping (address => mapping(address => address)) userTokenDAO;

    IMemberRegistry MR;

    constructor() {
        MR = IMemberRegistry(address(new MemberRegistry()));
        
    }

    /*//////////////////////////////////////////////////////////////
                                 errors
    //////////////////////////////////////////////////////////////*/



    /*//////////////////////////////////////////////////////////////
                                 events
    //////////////////////////////////////////////////////////////*/

    event newDAOCreated(address indexed DAO, address indexed token_);
    event isNowMember(address indexed who, uint indexed where, address indexed DAO);

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
        userTokenDAO[msg.sender][BaseTokenAddress_] = newDAO;

        emit newDAOCreated(newDAO, BaseTokenAddress_);
    }

    /// @notice creates exclusionary sub-unit
    /// @param: metaData_: any, preferably ipfs link to descriptive account
    /// @param: tokens_: ownable entities leveraged for discrimination
    /// @param: balances_: required quantities
    function subSet(
        address[] tokens_,
        uint[] balances_,
        bytes memory metaData_
    ) 
    external 
    returns 
    (uint subEntityId) {



        //emit subSetCreated(IDDD , mainset);
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
