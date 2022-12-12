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
    // mapping(address => mapping(address => address)) userTokenDAO;
    /// @dev useless? : allegience dynamic
    mapping(uint256 => Membrane) getMembraneById;
    mapping(address => uint256) usesMembrane;
    mapping(address => address) childParentDAO;
    mapping(address => address[]) topLevelPath;
    mapping(uint256 => ExternallCall) getExternalCall;

    IMemberRegistry MR;

    constructor() {
        MR = IMemberRegistry(address(new MemberRegistry()));
    }

    /*//////////////////////////////////////////////////////////////
                                 errors
    //////////////////////////////////////////////////////////////*/

    error nullTopLayer();
    error NotCoreMember(address who_);
    error aDAOnot();
    error membraneNotFound();
    error SubDAOLimitReached();
    error NonR();

    /*//////////////////////////////////////////////////////////////
                                 events
    //////////////////////////////////////////////////////////////*/

    event newDAOCreated(address indexed DAO, address indexed token);
    event isNowMember(address indexed who, uint256 indexed where, address indexed DAO);
    event CreatedMembrane(uint256 id, bytes metadata);
    event DAOchangedMembrane(address DAO, uint256 membrane);
    event subDAOCreated(address indexed parentDAO, address indexed subDAO, address indexed creator);
    event CreatedExternalCall(address indexed willCall, address indexed createdBy, bytes callData);
    /*//////////////////////////////////////////////////////////////
                                 public
    //////////////////////////////////////////////////////////////*/

    function createDAO(address BaseTokenAddress_) public returns (address newDAO) {
        newDAO = address(new DAOinstance(BaseTokenAddress_, msg.sender, address(MR)));
        daoOfId[uint160(bytes20(newDAO))] = newDAO;
        daosOfToken[BaseTokenAddress_].push(newDAO);
        /// @dev make sure membership determination (allegience) accounts for overwrites
        // userTokenDAO[msg.sender][BaseTokenAddress_] = newDAO;

        emit newDAOCreated(newDAO, BaseTokenAddress_);
    }

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

    /// @notice enshrines exclusionary sub-unit
    /// @param membraneID_: border materiality
    /// @param parentDAO_: parent
    /// @notice @security the creator of the subdao custodies assets
    function createSubDAO(uint256 membraneID_, address parentDAO_) external returns (address subDAOaddr) {
        address internalT = iInstanceDAO(parentDAO_).internalTokenAddress();
        if (MR.balanceOf(msg.sender, iInstanceDAO(parentDAO_).baseID()) == 0) revert NotCoreMember(msg.sender);
        if (daosOfToken[internalT].length > 99) revert SubDAOLimitReached();
        /// @dev membership sufficient for base layer grieffing attack

        iInstanceDAO parentInstance = iInstanceDAO(parentDAO_);
        iInstanceDAO childInstance;

        uint256 entityID = parentInstance.incrementSubDAO() * parentInstance.baseID();

        subDAOaddr = createDAO(internalT);
        childInstance = iInstanceDAO(subDAOaddr);

        usesMembrane[subDAOaddr] = membraneID_;
        daoOfId[entityID] = parentDAO_;

        childParentDAO[subDAOaddr] = parentDAO_;

        address[] memory parentPath = topLevelPath[parentDAO_];
        topLevelPath[subDAOaddr] = new address[](parentPath.length + 1);

        if (parentPath.length > 0) {
            uint256 i = 1;
            for (i; i <= parentPath.length;) {
                topLevelPath[subDAOaddr][i] = parentPath[i - 1];
                unchecked {
                    ++i;
                }
            }
            topLevelPath[subDAOaddr][0] = parentDAO_;
        }

        subDAOaddr = address(childInstance);

        childInstance.mintMembershipToken(msg.sender);

        emit subDAOCreated(parentDAO_, subDAOaddr, msg.sender);
    }

    function setMembrane(address DAO_, uint256 membraneID_) external returns (bool) {
        if (!isDAO(DAO_)) revert aDAOnot();
        if (!(msg.sender == DAO_)) revert aDAOnot();
        if (getMembraneById[membraneID_].tokens.length == 0) revert membraneNotFound();

        usesMembrane[DAO_] = membraneID_;
        emit DAOchangedMembrane(DAO_, membraneID_);
        return true;
    }

    function createExternalCall(address callPoint_, bytes memory callData_) external returns (uint256 id) {
        ExternallCall memory ecALL;
        ecALL.callPointAddress = callPoint_;
        ecALL.callData = callData_;
        ecALL.lastCalledAt = block.timestamp + 5 days;
        /// @dev is this feature worth the risks?
        ecALL.eligibleCaller = tx.origin;

        id = uint256(keccak256(callData_)) - block.timestamp;
        getExternalCall[id] = ecALL;

        emit CreatedExternalCall(callPoint_, msg.sender, callData_);
    }

    function prepLongDistanceCall(uint256 id_) external returns (ExternallCall memory) {
        if ((getExternalCall[id_].lastCalledAt) >= block.timestamp) revert NonR();
        getExternalCall[id_].lastCalledAt = block.timestamp + 5 days;
        return getExternalCall[id_];
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

    function entityData(uint256 id_) external view returns (bytes memory) {
        return getMembraneById[id_].meta;
    }

    function getMembrane(uint256 id_) external view returns (Membrane memory) {
        return getMembraneById[id_];
    }

    function isMembrane(uint256 id_) external view returns (bool) {
        return (getMembraneById[id_].tokens.length > 0);
    }

    function getMemberRegistryAddr() external view returns (address) {
        return address(MR);
    }

    function inUseMembraneId(address DAOaddress_) public view returns (uint256 ID) {
        return usesMembrane[DAOaddress_];
    }

    function getInUseMembraneOfDAO(address DAOAddress_) public view returns (Membrane memory) {
        return getMembraneById[usesMembrane[DAOAddress_]];
    }

    function getParentDAO(address child_) public view returns (address) {
        return childParentDAO[child_];
    }

    function getTrickleDownPath(address floor_) external view returns (address[] memory path) {
        path = topLevelPath[floor_].length > 0 ? topLevelPath[floor_] : new address[](1);
    }

    function getDAOsOfToken(address parentToken) external view returns (address[] memory) {
        return daosOfToken[parentToken];
    }

    function getLongDistanceCall(uint256 id_) external view returns (ExternallCall memory) {
        return getExternalCall[id_];
    }
}
