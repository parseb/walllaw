// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IAbstract.sol";
import "./interfaces/iInstanceDAO.sol";
import "./interfaces/IoDAO.sol";
import "./interfaces/IMember1155.sol";
import "./interfaces/IDAO20.sol";
import "./interfaces/ITokenFactory.sol";

contract AbstractAccount is IAbstract {
    address currentAgent;
    address public owner;
    address MemberRegistryAddr;
    // IoDAO ODAO;

    mapping(address => uint256) userNonce;

    /// @notice stores gas allawance for gassless execution of operations [address of instance][gas allowance]
    mapping(address => uint256) instanceGasAllocation;

    mapping(address => bool) authorized;

    mapping(address => BankDeposit[]) UserBankDeposits;

    event AbstractCall(address from, address indexed to);
    event NewDeposit(address from, address to);

    error AbstractA_AgencyAlreadyManifesting();
    error AbstractA_CallFailed();
    error AbstractA_AddressZero();
    error AbstractA_OnlyOwner();
    error AbstractA_Unauthorized();
    error AbstractA_NotADAO();
    error AbstractA_InvalidNonce();

    modifier onlyAutorized() {
        if (!authorized[msg.sender]) revert AbstractA_Unauthorized();
        _;
    }

    function addGasTo(address walllawInstance_) external payable returns (uint256 newAllawance) {
        if (walllawInstance_ == address(0)) revert AbstractA_AddressZero();
        instanceGasAllocation[walllawInstance_] += msg.value;
        return instanceGasAllocation[walllawInstance_];
    }

    constructor() {
        authorized[tx.origin] = true;
        owner = tx.origin;
        MemberRegistryAddr = msg.sender;
    }

    function depositFor(
        address forWho_,
        address toWhere_,
        uint256 amount_,
        uint256 nonce_,
        string memory transferData_,
        bytes memory signature_
    ) external onlyAutorized returns (bool s) {
        if (!(IoDAO(IMemberRegistry(MemberRegistryAddr).ODAOaddress()).isDAO(toWhere_))) revert AbstractA_NotADAO();
        currentAgent = forWho_;
        if (nonce_ != userNonce[forWho_] ) revert AbstractA_InvalidNonce();
        unchecked { ++ userNonce [forWho_]; }

        iInstanceDAO DAO = iInstanceDAO(toWhere_);

        BankDeposit memory BD;
        BD.DAOinstance = toWhere_;
        BD.originator = forWho_;
        BD.transferDATA = transferData_;
        BD.signature = signature_;
        BD.nonce = userNonce[currentAgent];

        UserBankDeposits[forWho_].push(BD);

        /// @todo verify signature
        address internalT = DAO.internalTokenAddress();
        IERC20 baseT = IERC20(DAO.baseTokenAddress());

        baseT.transferFrom(msg.sender, address(this), amount_);
        baseT.approve(internalT, type(uint256).max);

        s = IDAO20(internalT).wrapMintFor(amount_);
        s = true;
        require(s);

        delete currentAgent;
        emit NewDeposit(forWho_, toWhere_);
    }

    function authorizeAgent(address who_) external onlyAutorized returns (bool) {
        authorized[who_] = !authorized[who_];
    }

    function abstractCall(UserOperation memory UO) external returns (bool s) {
        if (currentAgent != address(0)) revert AbstractA_AgencyAlreadyManifesting();
        if (userNonce[UO.sender] != UO.nonce - 1) revert AbstractA_AgencyAlreadyManifesting();
        if (msg.sender != owner) revert AbstractA_OnlyOwner();

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
