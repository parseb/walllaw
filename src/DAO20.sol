// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import "solmate/tokens/ERC20.sol";
import "./interfaces/IERC20.sol";

/// @notice Minimalist and gas efficient standard ERC1155 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC1155.sol)
contract DAO20 is ERC20 {
    address owner;
    IERC20 baseToken;

    constructor(address baseToken_, string memory name_, string memory symbol_, uint8 decimals_)
        ERC20(name_, symbol_, decimals_)
    {
        owner = msg.sender;
        baseToken = IERC20(baseToken_);
    }

    error NotOwner();

    modifier OnlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function wrapMint(address to, uint256 amt) external OnlyOwner returns (bool) {
        _mint(to, amt);
    }

    function unwrapBurn(address from, uint256 amt) external OnlyOwner returns (bool) {
        _burn(from, amt);
    }
}
