// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "./Member1155.sol";
import "./DAOinstance.sol";
import "./interfaces/IMember1155.sol";
import "./interfaces/iInstanceDAO.sol";
import "./interfaces/IoDAO.sol";


contract ODAO {
    mapping(uint256 => address) daoOfId;
    mapping(address => address[]) daosOfToken;
    mapping(address => mapping(address => address)) userTokenDAO;
    mapping(uint256 => Membrane) getMembraneById;
    mapping(address => uint256) usesMembrane;
    mapping(address => address) childParentDAO;
    /// stores in-use membrane of DAO instance
    


    IMemberRegistry MR;

    constructor() {
        MR = IMemberRegistry(address(new MemberRegistry()));
    }

    /*//////////////////////////////////////////////////////////////
                                 errors
    //////////////////////////////////////////////////////////////*/

    error nullTopLayer();
    error NotCoreMember();
    error aDAOnot();
    error NotDAOOwner();
    error membraneNotFound();

    /*//////////////////////////////////////////////////////////////
                                 events
    //////////////////////////////////////////////////////////////*/

    event newDAOCreated(address indexed DAO, address indexed token_);
    event isNowMember(address indexed who, uint256 indexed where, address indexed DAO);
    event subSetCreated(uint256 subUnitId, uint256 parentUnitId);
    event CreatedMembrane(uint256 id, bytes metadata);
    event DAOchangedMembrane(address DAO, uint256 membrane);

    /*//////////////////////////////////////////////////////////////
                                 public
    //////////////////////////////////////////////////////////////*/

    function createDAO(address BaseTokenAddress_) public returns (address newDAO) {
        newDAO = address(new DAOinstance(BaseTokenAddress_, msg.sender, address(MR)));
        daoOfId[uint160(bytes20(newDAO))] = newDAO;
        daosOfToken[BaseTokenAddress_].push(newDAO);
        /// @dev make sure membership determination (allegience) accounts for overwrites
        userTokenDAO[msg.sender][BaseTokenAddress_] = newDAO;
        /// creator in case of subdao

        emit newDAOCreated(newDAO, BaseTokenAddress_);
    }

    function createMembrane(address[] memory tokens_, uint256[] memory balances_, bytes memory meta_)
        public
        returns (uint256 id)
    {
        Membrane memory M;
        M.tokens = tokens_;
        M.balances = balances_;
        M.meta = meta_;
        uint256 id = uint256(keccak256(abi.encode(M)));
        getMembraneById[id] = M;

        emit CreatedMembrane(id, meta_);
    }

    /// @notice enshrines exclusionary sub-unit
    /// @param membraneID_: border materiality
    /// @param parentDAO_: parent
    function createSubDAO(uint256 membraneID_, address parentDAO_) external returns (address subDAOaddr) {
        address internalT = iInstanceDAO(parentDAO_).internalTokenAddr();

        if (MR.balanceOf(msg.sender, iInstanceDAO(parentDAO_).baseID()) == 0) revert NotCoreMember();
        subDAOaddr = createDAO(internalT);

        uint256 entityID = iInstanceDAO(parentDAO_).incrementSubDAO();

        usesMembrane[subDAOaddr] = membraneID_;
        daoOfId[entityID] = parentDAO_;
        daosOfToken[iInstanceDAO(parentDAO_).baseTokenAddress()].push(subDAOaddr);

        childParentDAO[parentDAO_] = subDAOaddr;
        iInstanceDAO(subDAOaddr).giveOwnership(msg.sender);
        //  require( iInstanceDAO(subDAOaddr).owner()  == msg.sender, "not owner" );
        //  require( IERC20(iInstanceDAO(subDAOaddr).internalTokenAddr()).owner() == address(subDAOaddr), "DAO not owner");
    }

    function setMembrane(address DAO_, uint256 membraneID_) external returns (bool) {
        if (msg.sender == (iInstanceDAO(DAO_).owner())) revert NotDAOOwner();
        if (!isDAO(DAO_)) revert aDAOnot();
        if (getMembraneById[membraneID_].tokens.length == 0) revert membraneNotFound();

        usesMembrane[DAO_] = membraneID_;
        emit DAOchangedMembrane(DAO_, membraneID_);
    }

    /*//////////////////////////////////////////////////////////////
                                 VIEW
    //////////////////////////////////////////////////////////////*/

    /// @notice checks if address is a registered DAOS
    /// @dev used to authenticate membership minting
    /// @param toCheck_: address to check if registered as DAO
    function isDAO(address toCheck_) public view returns (bool) {
        return (daoOfId[uint160(bytes20(toCheck_))] == toCheck_);
    }

    /// @notice returns the DAO instance to which the given id_ belongs to
    function getDAOfromID(uint256 id_) public view returns (address) {
        return daoOfId[id_];
    }

    function entityData(uint256 id) external view returns (bytes memory) {
        return getMembraneById[id].meta;
    }

    function getMembrane(uint256 id) external view returns (Membrane memory) {
        return getMembraneById[id];
    }

    function getMemberRegistryAddr() external view returns (address) {
        return address(MR);
    }

    function inUseMembrane(address DAOaddress_) public view returns (Membrane memory M) {
        M = getMembraneById[usesMembrane[DAOaddress_]];
    }
}
