// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "./interfaces/IMember1155.sol";

contract DAOinstance {
    /// inflation rate for base wrapped token ( ponzi / deficit financing )
    uint256[2] public inflationRatePerSec;
    /// [rate, lastSettled]
    address[2] private ownerStore;

    IERC20 public BaseToken;
    IMemberRegistry iMR;

    uint256 public baseID;
    uint256 localID;

    constructor(address baseToken_, address owner_, address MemberRegistry_) {
        BaseToken = IERC20(baseToken_);
        baseID = uint160(bytes20(address(this)));
        ownerStore = [owner_, owner_];
        iMR = IMemberRegistry(MemberRegistry_);
    }

    /*//////////////////////////////////////////////////////////////
                                 events
    //////////////////////////////////////////////////////////////*/

    event LocalIncrement(uint256 localID);
    event RateAdjusted();

    /*//////////////////////////////////////////////////////////////
                                 errors
    //////////////////////////////////////////////////////////////*/

    error NotOwner();

    /*//////////////////////////////////////////////////////////////
                                 modifiers
    //////////////////////////////////////////////////////////////*/

    modifier onlyOwner() {
        if (msg.sender != ownerStore[1]) revert NotOwner();
        _;
    }

    // require(msg.sender == owner(), "Only Owner");

    function proposeStateChange() public returns (bool) {}

    /// @notice ownership change function. execute twice
    function giveOwnership(address newOwner_) external onlyOwner returns (address currentOwner) {
        ownerStore = ownerStore[0] == newOwner_ ? [newOwner_, newOwner_] : [newOwner_, msg.sender];
    }

    /// @dev @todo: @security review token wrap
    function wrapMint(address baseToken_, uint256 amount_, address to_) public returns (bool s) {
        s = BaseToken.transferFrom(msg.sender, address(this), amount_);
        s = s && iMR._wrapMint(address(BaseToken), amount_, to_);
    }

    function unwrapBurn(address baseToken_, uint256 amount_, address from_) public returns (bool s) {
        s = s && BaseToken.transfer(from_, amount_);
        s = iMR._unwrapBurn(from_, amount_, address(BaseToken));
    }

    /// @dev prescriptive ? limit max inflation rate
    function setPerSecondInterestRate(uint256 ratePerSec) external onlyOwner returns (bool) {
        inflationRatePerSec[0] = ratePerSec;

        emit RateAdjusted();
    }

    /*//////////////////////////////////////////////////////////////
                                 misc
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                                 VIEW
    //////////////////////////////////////////////////////////////*/

    function incrementID() private returns (uint256) {
        localID = (localID + 1) * baseID;
        emit LocalIncrement(localID);
    }

    /*//////////////////////////////////////////////////////////////
                                 VIEW
    //////////////////////////////////////////////////////////////*/

    function owner() public view returns (address) {
        return ownerStore[1];
    }
}
