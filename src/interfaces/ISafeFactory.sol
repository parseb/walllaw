// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

interface ISafeFactory {
    function proxyRuntimeCode() external pure returns (bytes memory);
    function proxyCreationCode() external pure returns (bytes memory);
    function createProxy(address singleton, bytes calldata) external returns (address);
    // function createProxyWithNonce(address _singleton, bytes  initializer, uint256 saltNonce)
    //     external
    //     returns (address proxy);

    // function createProxyWithCallback(address _singleton, bytes calldata , uint256 saltNonce, bytes calldata callback)
    //     external
    //     returns (address proxy);

    // function calculateCreateProxyWithNonceAddress(address _singleton, bytes calldata, uint256 saltNonce)
    //     external
    //     returns (address proxy);
}
