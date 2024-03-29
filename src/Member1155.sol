// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./oDAO.sol";
import "./MembraneRegistry.sol";
import "./DAO20Factory.sol";

import "solmate/tokens/ERC1155.sol";
import "./interfaces/IoDAO.sol";
import "./interfaces/iInstanceDAO.sol";
import "./interfaces/IMembrane.sol";

/// @author BPA, parseb
/// @custom:experimental This is an experimental contract.
/// @notice Membership Registry contract.
contract MemberRegistry is ERC1155 {
    address public ODAOaddress;
    address public MembraneRegistryAddress;
    address public DAO20FactoryAddress;

    IoDAO oDAO;
    IMembrane IMB;

    mapping(address => address[]) endpointsOf;
    mapping(uint256 => string) tokenUri;
    mapping(uint256 => uint256) uidTotalSupply;
    mapping(address => uint256[]) idsOf;
    mapping(uint256 => address[]) allMemberCards;

    constructor() {
        DAO20FactoryAddress = address(new DAO20Factory());
        ODAOaddress = address(new ODAO(DAO20FactoryAddress));

        ITokenFactory(DAO20FactoryAddress).setODAO(ODAOaddress);

        MembraneRegistryAddress = address(new MembraneRegistry(ODAOaddress));

        oDAO = IoDAO(ODAOaddress);
        IMB = IMembrane(MembraneRegistryAddress);
    }

    /*//////////////////////////////////////////////////////////////
                                 errors
    //////////////////////////////////////////////////////////////*/

    error MR1155_Untransferable();
    error MR1155_onlyOdao();
    error MR1155_UnregisteredDAO();
    error MR1155_UnauthorizedID();
    error MR1155_InvalidMintID();
    error MR1155_AlreadyIn();
    error MR1155_OnlyMembraneRegistry();
    error MR1155_OnlyODAO();

    modifier onlyDAO() {
        if (!oDAO.isDAO(msg.sender)) revert MR1155_UnregisteredDAO();
        _;
    }

    modifier onlyMembraneR() {
        if (msg.sender != MembraneRegistryAddress) revert MR1155_OnlyMembraneRegistry();
        _;
    }
    /*//////////////////////////////////////////////////////////////
                                 events
    //////////////////////////////////////////////////////////////*/

    event isNowMember(address who, uint256 id, address dao);

    /*//////////////////////////////////////////////////////////////
                                 external
    //////////////////////////////////////////////////////////////*/

    /// @notice mints membership token provided candidate agent satisfies conditions
    /// @param who_ address that will become member
    /// @param id_ id of organisational entity
    function makeMember(address who_, uint256 id_) external onlyDAO returns (bool) {
        /// the id_ of any subunit  is a multiple of DAO address
        if (!(id_ % uint160(bytes20(msg.sender)) == 0)) {
            /// @dev
            revert MR1155_InvalidMintID();
        }
        /// does not yet have member token
        if (balanceOf[who_][id_] > 0) revert MR1155_AlreadyIn();

        /// if first member to join, fetch cell metadata
        /// @todo get membrane meta or dao specific metadata
        // if (tokenUri[id_].length == 0) tokenUri[id_] = oDAO.entityData(id_);

        /// mint membership token
        _mint(who_, id_, 1, abi.encode(tokenUri[id_]));
        idsOf[who_].push(id_);
        allMemberCards[id_].push(who_);

        emit isNowMember(who_, id_, msg.sender);
        return balanceOf[who_][id_] == 1;
    }

    function setUri(string memory uri_) external onlyDAO {
        tokenUri[uint160(bytes20(msg.sender))] = uri_;
    }

    /*//////////////////////////////////////////////////////////////
                                 view
    //////////////////////////////////////////////////////////////*/

    function uri(uint256 id) public view override returns (string memory) {
        return tokenUri[id];
    }

    function getUriOf(address who_) external view returns (string memory) {
        return tokenUri[uint160(bytes20(who_))];
    }

    function getActiveMembershipsOf(address who_) external view returns (address[] memory entities) {
        uint256[] memory ids = idsOf[who_];
        uint256 i;
        entities = new address[](ids.length);
        for (i; i < ids.length;) {
            if (balanceOf[who_][ids[i]] > 0) entities[i] = address(uint160(ids[i]));
            unchecked {
                i++;
            }
        }
    }

    function getctiveMembersOf(address instance_) external view returns (address[] memory memb) {
        uint256 id_ = uint160(bytes20(instance_));
        address[] memory owners = allMemberCards[id_];
        uint256 i;

        memb = new address[](owners.length);

        for (i; i < owners.length;) {
            if (balanceOf[owners[i]][id_] > 0) memb[i] = owners[i];
            unchecked {
                i++;
            }
        }
    }

    function pushIsEndpointOf(address dao_, address endpointOwner_) external {
        if (msg.sender != ODAOaddress) revert MR1155_OnlyODAO();
        // endpoints.push(dao_);
        endpointsOf[endpointOwner_].push(dao_);
    }

    /*//////////////////////////////////////////////////////////////
                                 override
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data)
        public
        override
    {
        if (from != address(0) || to != address(0)) revert MR1155_Untransferable();

        super.safeTransferFrom(from, to, id, amount, data);
    }

    /// @notice custom burn for gCheck functionality
    function gCheckBurn(address who_, address DAO_) external onlyMembraneR returns (bool) {
        uint256 id_ = uint160(bytes20(DAO_));
        _burn(who_, id_, balanceOf[who_][id_]);
        iInstanceDAO(DAO_).gCheckPurge(who_);
        return balanceOf[who_][id_] == 0;
    }

    /// @notice how many tokens does the given id_ has. Useful for checking how many members a DAO has.
    /// @notice id_ is always the uint(address of DAO)
    /// @param id_ id to check how many minted tokens it has associated
    function howManyTotal(uint256 id_) public view returns (uint256) {
        return uidTotalSupply[id_];
    }
    ///@dev deprecate for howManyMembers()

    /// @notice returns how many members the provided instance has
    /// @param instance querried instance
    function howManyMembers(address instance) external view returns (uint256) {
        return uidTotalSupply[uint160(bytes20(instance))];
    }

    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal override {
        super._mint(to, id, amount, data);
        uidTotalSupply[id] += 1;
    }

    function _burn(address from, uint256 id, uint256 amount) internal override {
        super._burn(from, id, amount);
        uidTotalSupply[id] -= 1;
    }

    function _batchBurn(address from, uint256[] memory ids, uint256[] memory amounts) internal override {
        revert("_batchBurn");
    }

    function _batchMint(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override
    {
        revert("_batchMint");
    }

    function getEndpointsOf(address ofWhom_) external view returns (address[] memory) {
        return endpointsOf[ofWhom_];
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public override {
        revert("safeBatchTransferFrom");
    }
}
