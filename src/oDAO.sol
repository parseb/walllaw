// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./DAOinstance.sol";
import "./interfaces/IMember1155.sol";
import "./interfaces/iInstanceDAO.sol";
import "./interfaces/IoDAO.sol";
import "./interfaces/IMembrane.sol";
import "./interfaces/IAbstract.sol";

contract ODAO {
    bool isInit;
    mapping(uint256 => address) daoOfId;
    // mapping(address => address[]) daosOfToken;
    mapping(address => address) childParentDAO;
    mapping(address => address[]) topLevelPath;
    IMemberRegistry MR;
    address public MB;
    address public DAO20FactoryAddress;
    IAbstract AbstractA;
    uint256 constant MAX_160 = type(uint160).max;

    constructor(address DAO20Factory_) {
        MR = IMemberRegistry(msg.sender);
        DAO20FactoryAddress = DAO20Factory_;
        isInit = true;
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
    error FailedToSetMembrane();

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
            AbstractA = IAbstract(MR.AbstractAddr());
            isInit = false;
        }
        // if (BaseTokenAddress_ is internalT and msg.sig != createSubDAO ) revert @todo passing internal intently
        newDAO = address(new DAOinstance(BaseTokenAddress_, msg.sender, address(MR),DAO20FactoryAddress ));
        daoOfId[uint160(bytes20(newDAO))] = newDAO;
        // daosOfToken[BaseTokenAddress_].push(newDAO);
        // if (msg.sig == this.createDAO.selector) MR.pushAsRoot(newDAO);
        if (msg.sig == this.createDAO.selector) iInstanceDAO(newDAO).mintMembershipToken(msg.sender);
        emit newDAOCreated(newDAO, BaseTokenAddress_);
    }

    //// @security ?: can endpoint-onEndpoint create. remove multiple endpoit.
    ///  --------------- create sub-endpoints for endpoint? @todo

    /// @notice creates child entity subDAO provided a valid membrane ID is given. To create an enpoint use sender address as integer. uint160(0xyourAddress)
    /// @param membraneID_: constituent border conditions and chemestry
    /// @param parentDAO_: parent DAO
    /// @notice @security the creator of the subdao custodies assets
    function createSubDAO(uint256 membraneID_, address parentDAO_) external returns (address subDAOaddr) {
        if (MR.balanceOf(msg.sender, iInstanceDAO(parentDAO_).baseID()) == 0) revert NotCoreMember(msg.sender);
        address internalT = iInstanceDAO(parentDAO_).internalTokenAddress();
        // if (daosOfToken[internalT].length > 9_999) revert SubDAOLimitReached();

        subDAOaddr = createDAO(internalT);
        bool isEndpoint = (membraneID_ < MAX_160) && (address(uint160(membraneID_)) == msg.sender);
        isEndpoint
            ? IMembrane(MB).setMembraneEndpoint(membraneID_, subDAOaddr, msg.sender)
            : IMembrane(MB).setMembrane(membraneID_, subDAOaddr);
        if (isEndpoint) MR.pushIsEndpointOf(subDAOaddr, msg.sender);

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

        iInstanceDAO(subDAOaddr).mintMembershipToken(msg.sender);
        emit subDAOCreated(parentDAO_, subDAOaddr, msg.sender);
    }

    function _msgSender() private view returns (address) {
        if (msg.sender == address(AbstractA)) return AbstractA.currentAccount();

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
}
