pragma solidity ^0.8.0;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";

interface IDAO20 is IERC20 {
    function wrapMint(uint256 amt) external returns (bool s);

    function base() external view returns (address b);

    function owner() external view returns (address o);

    function unwrapBurn(uint256 amtToBurn_) external returns (bool s);

    function inflationaryMint(uint256) external returns (bool);

    function mintInitOne(address) external returns (bool);

    function burnInProgress() external view returns (address);

    function wrapMintFor(uint256 amount_) external returns (bool);

    function baseTokenAddress() external view returns (address);

    //////////////////
}
