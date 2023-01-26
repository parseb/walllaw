// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct ExtCall {
    address[] contractAddressesToCall;
    bytes[] dataToCallWith;
    uint256 createdAtOrLastCalledAt;
    string shortDescription;
}

interface IExternalCall {
    function createExternalCall(address[] memory contracts_, bytes[] memory callDatas_, string memory description_)
        external
        returns (uint256);

    function getExternalCallbyID(uint256 id) external view returns (ExtCall memory);

    function updateLastExecuted(uint256 whatExtCallId_) external returns (bool);
}
