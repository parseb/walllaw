pragma solidity ^0.8.13;

contract MockExternalSameStorageLayout {
    uint256 public baseID;
    uint256 public baseInflationRate;
    uint256 public baseInflationPerSec;
    uint256 public localID;
    uint256 public instantiatedAt;
    address public ODAO;
    address[2] private ownerStore;
    // IERC20 public BaseToken;
    // IMemberRegistry iMR;
    // DAO20 public internalToken;
    mapping(address => mapping(address => uint256[2])) userSignal;
    mapping(address => uint256[2]) subunitPerSec;
    mapping(address => uint256[]) redistributiveSignal;
    mapping(uint256 => mapping(address => uint256)) public expressed;
    mapping(uint256 => address[]) expressors;

    address miniOwner;

    constructor() {
        baseID = 5;
    }

    function changeODAOAddress(uint256 O_O) external {
        baseID = O_O;
    }
}
