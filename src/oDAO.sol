// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./DAOinstance.sol";
import "./interfaces/IMember1155.sol";
import "./interfaces/iInstanceDAO.sol";
import "./interfaces/IoDAO.sol";
import "./interfaces/IMembrane.sol";
import "./interfaces/ISafeFactory.sol";
import "./interfaces/ISafe.sol";

import "./utils/libSafeFactoryAddresses.sol";

contract ODAO {
    bool isInit;
    mapping(uint256 => address) daoOfId;
    mapping(address => address) childParentDAO;
    mapping(address => address[]) topLevelPath;
    mapping(address => address[]) links;
    IMemberRegistry MR;
    ISafeFactory SF;
    address public MB;
    address public DAO20FactoryAddress;
    uint256 constant MAX_160 = type(uint160).max;

    constructor(address DAO20Factory_) {
        MR = IMemberRegistry(msg.sender);
        DAO20FactoryAddress = DAO20Factory_;

        SF = ISafeFactory(SafeFactoryAddresses.factoryAddressForChainId(block.chainid));
        isInit = true;
    }

    /*//////////////////////////////////////////////////////////////
                                 errors
    //////////////////////////////////////////////////////////////*/

    error nullTopLayer();
    error NotCoreMember(address who_);
    error notDAO();
    error membraneNotFound();
    error SubDAOLimitReached();
    error NonR();
    error FailedToSetMembrane();
    error OnlySubDao();
    error FailedToInitSafe();

    /*//////////////////////////////////////////////////////////////
                                 events
    //////////////////////////////////////////////////////////////*/

    event newDAOCreated(address indexed DAO, address indexed token);
    event subDAOCreated(address indexed parentDAO, address indexed subDAO, address indexed creator);

    /*//////////////////////////////////////////////////////////////
                                 public
    //////////////////////////////////////////////////////////////*/

    /// @notice creates a new DAO gien an ERC20
    /// @param BaseTokenAddress_ ERC20 token contract address
    function createDAO(address BaseTokenAddress_) public returns (address newDAO) {
        //// @dev
        if (isInit) {
            MB = MR.MembraneRegistryAddress();
            isInit = false;
        }

        newDAO = address(new DAOinstance(BaseTokenAddress_, msg.sender, address(MR),DAO20FactoryAddress ));
        daoOfId[uint160(bytes20(newDAO))] = newDAO;
        if (msg.sig == this.createDAO.selector) {
            iInstanceDAO(newDAO).mintMembershipToken(msg.sender);
            links[BaseTokenAddress_].push(newDAO);
        }
        emit newDAOCreated(newDAO, BaseTokenAddress_);
    }

    /// @notice To create a subDAO provide a valid membrane ID and parent address.
    /// @notice To create an enpoint use sender address as membrane id. `uint160(0xyourAddress)`.
    /// @notice To create a Safe endpoint use address of parent as membrane id. `uint160(parentDAO_)`.
    /// @param membraneID_: membrane ID to delimit and identify resulting instance.
    /// @param parentDAO_: parent under which the new instance is spawned.
    /// @notice @security the creator of the subdao custodies assets
    function createSubDAO(uint256 membraneID_, address parentDAO_) external returns (address subDAOaddr) {
        if (!isDAO(parentDAO_)) revert notDAO();
        if (MR.balanceOf(msg.sender, iInstanceDAO(parentDAO_).baseID()) == 0) revert NotCoreMember(msg.sender);
        address internalT = iInstanceDAO(parentDAO_).internalTokenAddress();
        bool isEndpoint = (membraneID_ < MAX_160) && (address(uint160(membraneID_)) == msg.sender);
        bool isSafe;
        if (!isEndpoint && (uint160(membraneID_) == uint160(parentDAO_))) {
            bytes memory x = abi.encode(links[parentDAO_].length);
            address subDAOaddr = SF.createProxy(SafeFactoryAddresses.getSingletonAddressForChainID(block.chainid), x);
            address[] memory OWs = MR.getctiveMembersOf(parentDAO_);
            uint256 t = OWs.length / 2 + 1;
            ISafe(subDAOaddr).setup(OWs, t, address(0), x, address(0), address(0), 0, subDAOaddr);
            if (ISafe(subDAOaddr).getThreshold() != t) revert FailedToInitSafe();
            isSafe = true;
        } else {
            subDAOaddr = createDAO(internalT);
            isEndpoint
                ? IMembrane(MB).setMembraneEndpoint(membraneID_, subDAOaddr, msg.sender)
                : IMembrane(MB).setMembrane(membraneID_, subDAOaddr);
            if (isEndpoint) MR.pushIsEndpointOf(subDAOaddr, msg.sender);
        }

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
        }

        topLevelPath[subDAOaddr][0] = parentDAO_;
        links[parentDAO_].push(subDAOaddr);

        if (!isSafe) iInstanceDAO(subDAOaddr).mintMembershipToken(msg.sender);
        emit subDAOCreated(parentDAO_, subDAOaddr, msg.sender);
    }

    function _msgSender() private view returns (address) {
        return msg.sender;
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

    /// @notice get address of member registru address
    function getMemberRegistryAddr() external view returns (address) {
        return address(MR);
    }

    /// @notice given a valid subDAO address, returns the address of the parent. If root DAO, returns address(0x0)
    /// @param child_ sub-DAO address. If root or non-existent, returns adddress(0x0)
    function getParentDAO(address child_) public view returns (address) {
        return childParentDAO[child_];
    }

    /// @notice returns the top-down path, or all the parents in a hierarchical, distance-based order, from closest parent to root.
    function getTrickleDownPath(address floor_) external view returns (address[] memory path) {
        path = topLevelPath[floor_].length > 0 ? topLevelPath[floor_] : new address[](1);
    }

    function DAO20FactoryAddr() external view returns (address) {
        return DAO20FactoryAddress;
    }

    function getLinksOf(address instanceOrToken_) external view returns (address[] memory) {
        return links[instanceOrToken_];
    }
}
