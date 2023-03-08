// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

//// ERC4337 too much
// struct UserOperation {

//     address sender;
//     uint256 nonce;
//     bytes initCode;
//     bytes callData;
//     uint256 callGasLimit;
//     uint256 verificationGasLimit;
//     uint256 preVerificationGas;
//     uint256 maxFeePerGas;
//     uint256 maxPriorityFeePerGas;
//     bytes paymasterAndData;
//     bytes signature;
// }

struct UserOperation {
    address sender;
    uint256 nonce;
    address daoInstance;
    bytes callData;
    bytes signature;
}

interface IAbstract {
    function abstractCall(UserOperation memory) external returns (bool);

    function currentAccount() external view returns (address);

    function owner() external view returns (address);

    function getNonceOfUser(address agent_) external view returns (uint256);
}