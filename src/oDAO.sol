// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "./DAOinstance.sol";
import "./interfaces/IMember1155.sol";
import "./interfaces/iInstanceDAO.sol";
import "./interfaces/IoDAO.sol";
import "./interfaces/IMembrane.sol";

contract ODAO {
    mapping(uint256 => address) daoOfId;
    mapping(address => address[]) daosOfToken;
    mapping(address => address) childParentDAO;
    mapping(address => address[]) topLevelPath;
    IMemberRegistry MR;
    address public MB;

    constructor() {
        MR = IMemberRegistry(msg.sender);
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
    event isNowMember(address indexed DAO, address indexed who, uint256 indexed where);
    event DAOchangedMembrane(address DAO, uint256 membrane);
    event subDAOCreated(address indexed parentDAO, address indexed subDAO, address indexed creator);
    /*//////////////////////////////////////////////////////////////
                                 public
    //////////////////////////////////////////////////////////////*/

    function createDAO(address BaseTokenAddress_) public returns (address newDAO) {
        newDAO = address(new DAOinstance(BaseTokenAddress_, msg.sender, address(MR)));
        daoOfId[uint160(bytes20(newDAO))] = newDAO;
        daosOfToken[BaseTokenAddress_].push(newDAO);

        emit newDAOCreated(newDAO, BaseTokenAddress_);
    }

    /// @notice enshrines exclusionary sub-unit
    /// @param membraneID_: border materiality
    /// @param parentDAO_: parent
    /// @notice @security the creator of the subdao custodies assets
    function createSubDAO(uint256 membraneID_, address parentDAO_) external returns (address subDAOaddr) {
        if (MR.balanceOf(msg.sender, iInstanceDAO(parentDAO_).baseID()) == 0) revert NotCoreMember(msg.sender);
        address internalT = iInstanceDAO(parentDAO_).internalTokenAddress();
        if (daosOfToken[internalT].length > 99) revert SubDAOLimitReached();
        /// @dev membership sufficient for base layer grieffing attack

        if (address(MB) == address(0)) MB = MR.MembraneRegistryAddress();

        subDAOaddr = createDAO(internalT);

        IMembrane(MB).setMembrane(membraneID_, subDAOaddr);
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

        iInstanceDAO(subDAOaddr).mintMembershipToken(msg.sender);
        emit subDAOCreated(parentDAO_, subDAOaddr, msg.sender);
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

    function getMemberRegistryAddr() external view returns (address) {
        return address(MR);
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
}
