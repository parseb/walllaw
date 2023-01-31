// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IoDAO.sol";
import "./interfaces/IExternalCall.sol";

contract ExternalCall is IExternalCall {
    IoDAO ODAO;

    mapping(uint256 => ExtCall) externalCallById;

    /// id of call => address of dao => lastExecuted
    mapping(uint256 => mapping(address => uint256)) lastExecutedorCreatedAt;

    /// dao nonce
    mapping(address => uint256) nonce;



    constructor(address odao_) {
        ODAO = IoDAO(odao_);
    }

    error ExternalCall_UnregisteredDAO();
    error ExternalCall_CallDatasContractsLenMismatch();

    modifier onlyDAO() {
        if (!ODAO.isDAO(msg.sender)) revert ExternalCall_UnregisteredDAO();
        _;
    }

    event NewExternalCall(address indexed CreatedBy, string description, uint256 createdAt);

    function createExternalCall(address[] memory contracts_, bytes[] memory callDatas_, string memory description_)
        external
        returns (uint256 idOfNew)
    {
        if (contracts_.length != callDatas_.length) revert ExternalCall_CallDatasContractsLenMismatch();
        ExtCall memory newCall;
        newCall.contractAddressesToCall = contracts_;
        newCall.dataToCallWith = callDatas_;
        newCall.shortDescription = description_;

        idOfNew = uint256(keccak256(abi.encode(newCall))) % 1 ether;
        externalCallById[idOfNew] = newCall;

        emit NewExternalCall(msg.sender, description_, block.timestamp);
    }

    function updateLastExecuted(uint256 whatExtCallId_) external onlyDAO returns (bool) {
        lastExecutedorCreatedAt[whatExtCallId_][msg.sender] = block.timestamp;
        return true;
    }

    function incrementSelfNonce() external onlyDAO {
        unchecked { ++ nonce[msg.sender]; }
    }

    function getExternalCallbyID(uint256 id_) external view returns (ExtCall memory) {
        return externalCallById[id_];
    }

    function isValidCall(uint256 id_) external view returns (bool) {
        return externalCallById[id_].contractAddressesToCall.length > 0;
    }

    function getNonceOf(address whom_) external view returns (uint256) {
        return nonce[whom_];
    }
}
