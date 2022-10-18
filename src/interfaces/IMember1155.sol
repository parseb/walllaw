// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IMemberRegistry {
    function makeMember(address from, address who_, uint256 id_) external returns (bool);

    function _wrapMint(address baseToken_, uint256 amount_, address to_) external returns (bool);
    function _unwrapBurn(address baseToken_, uint256 amount_, address from_) external returns (bool);
}
