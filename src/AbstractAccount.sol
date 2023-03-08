// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IAbstract.sol";

contract AbstractAccount is IAbstract {
    address currentAgent;
    address public owner;

    mapping(address => uint256) userNonce;

    /// @notice stores gas allawance for gassless execution of operations [address of instance][gas allowance]
    mapping(address => uint256) instanceGasAllocation;

    event AbstractCall(address from, address indexed to);

    error AgencyAlreadyManifesting();
    error CallFailed();
    error AddressZero();
    error OnlyOwner();

    function addGasTo(address walllawInstance_) external payable returns (uint256 newAllawance) {
        if (walllawInstance_ == address(0)) revert AddressZero();
        instanceGasAllocation[walllawInstance_] += msg.value;
        return instanceGasAllocation[walllawInstance_];
    }

    // struct UserOperation {
    //     address sender;
    //     uint256 nonce;
    //     address daoInstance;
    //     bytes callData;
    //     bytes signature;
    // }

    /// http://guild.xyz/walllaw
    /// LinkeGaard.eth
    /// Linkebeek community garden incorporated project. We use a walllaw to steer the evolution of the project by continuous and transparent of allocation of resources. Come talk to us to our market stall every sunday morning on Linkebeek Straße nr 7, from 10pm.
    /// http://explorer.walllaw.xyz/LinkeGaard.eth
    /// {"workspace":{description:"this is where we budget things",link:"http://linktoprojectedneedsandreviews.com"},"governance":{description:"this is where we talk about things", link:"http://www.discord.com"}

    constructor() {}

    function abstractCall(UserOperation memory UO) external returns (bool s) {
        if (currentAgent != address(0)) revert AgencyAlreadyManifesting();
        if (userNonce[UO.sender] != UO.nonce - 1) revert AgencyAlreadyManifesting();
        if (msg.sender != owner) revert OnlyOwner();

        uint256 gasStart = gasleft();
        currentAgent = UO.sender;

        (s,) = UO.daoInstance.call(UO.callData);

        require(s);
        unchecked {
            ++userNonce[UO.sender];
        }
        instanceGasAllocation[UO.daoInstance] -= (gasStart - gasleft());

        delete currentAgent;

        /// @dev tax?
        emit AbstractCall(UO.sender, UO.daoInstance);
    }

    function currentAccount() external view returns (address) {
        return currentAgent;
    }

    function getNonceOfUser(address agent_) external view returns (uint256) {
        return userNonce[agent_];
    }

    ////////// SIG Utils
    function getMessageHash(address _to, uint256 _amount, string memory _message, uint256 _nonce)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verify(
        address _signer,
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSig(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSig(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSig(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSig(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}