pragma solidity ^0.8.10;

interface IGSFactory {
    function createSafeL2(address forParent_) external returns (address newSafe);
    function _setInitODAOAddr() external;
}
