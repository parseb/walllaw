// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import "solmate/tokens/ERC20.sol";
// import "./interfaces/IERC20.sol";

/// @notice Minimalist and gas efficient standard ERC1155 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC1155.sol)
contract DAO20 is ERC20 {
    address public owner;
    /// IERC20 baseToken;

    constructor(address baseToken_, string memory name_, string memory symbol_, uint8 decimals_)
        ERC20(name_, symbol_, decimals_)
    {
        owner = msg.sender;
        /// baseToken = IERC20(baseToken_);
    }

    error NotOwner();

    modifier OnlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /// Only Owner //////////
    function wrapMint(address to, uint256 amt) external OnlyOwner returns (bool) {
        _mint(to, amt);
        return true;
    }

    function unwrapBurn(address from, uint256 amt) external OnlyOwner returns (bool) {
        _burn(from, amt);
        return true;
    }

    /// ////////////////////

    /// Override //////////////

    //// @dev @security DAO token should be transferable only to DAO instances or owner (resource basket multisig)
    /// there's some potential attack vectors on inflation and redistributive signals (re-enterange like)
    /// two options: embrace the messiness |OR| allow transfers only to owner and sub-entities


    function transfer(address to, uint256 amount) public override returns (bool) {
        /// limit transfers
        require(msg.sender == owner, "msg sender not owner");
        return super.transfer(to,amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        /// limit transfers
        require(msg.sender == owner, "msg sender not owner");
        if (from == owner) _mint(owner, amount);
        require(super.transferFrom(from,to,amount));
        return true;
    }

    // function _balanceOf(address who_) external returns (uint) {
    //     return balanceOf[who_];
    // }

    // function _totalSupply() external returns (uint) {
    //     return this.totalSupply;
    // }

}
