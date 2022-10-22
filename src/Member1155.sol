// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/tokens/ERC1155.sol";
import "./interfaces/IoDAO.sol";
import "./interfaces/iInstanceDAO.sol";

contract MemberRegistry is ERC1155 {
    IoDAO oDAO;

    mapping(uint256 => bytes) tokenUri;

    constructor() {
        oDAO = IoDAO(msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                                 errors
    //////////////////////////////////////////////////////////////*/

    error Untransferable();
    error onlyOdao();
    error UnregisteredDAO();
    error UnauthorizedID();
    error InvalidMintID();
    error AlreadyIn();

    modifier onlyDAO() {
        if (!oDAO.isDAO(msg.sender)) revert UnregisteredDAO();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 events
    //////////////////////////////////////////////////////////////*/

    event isNowMember(address who, uint256 id, address dao);

    /*//////////////////////////////////////////////////////////////
                                 external
    //////////////////////////////////////////////////////////////*/


    /// mints membership token to provided address
    
    function makeMember(address who_, uint256 id_) external onlyDAO returns (bool) {
        /// the id_ of any subunit  is a multiple of DAO address
        if (! (id_ % uint160(bytes20(msg.sender)) == 0)) { /// @dev
            revert InvalidMintID();
        }

        /// does not yet have member token
        if (balanceOf[who_][id_] > 0) revert AlreadyIn();

        /// if first member to join, fetch cell metadata
        if (tokenUri[id_].length == 0) tokenUri[id_] = iInstanceDAO(msg.sender).entityData(id_);

        /// mint membership token
        _mint(who_, id_, 1, tokenUri[id_]);

        emit isNowMember(who_, id_, msg.sender);
        return true;
    }

    /*//////////////////////////////////////////////////////////////
                                 view
    //////////////////////////////////////////////////////////////*/

    function uri(uint256 id) public view override returns (string memory) {
        return string(tokenUri[id]);
    }

    /*//////////////////////////////////////////////////////////////
                                 override
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data)
        public
        override
    {
        if (from != address(0) || to != address(0)) revert Untransferable();
    }

    /// misc

    // /// @dev duplicated
    // function wTokenId(address baseTokenAddr) public pure returns (uint256) {
    //     return uint160(bytes20(baseTokenAddr)) - 1;
    // }
}
