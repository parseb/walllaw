// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "./interfaces/IMember1155.sol";
import "./DAO20.sol";

contract DAOinstance {
    /// inflation rate for base wrapped token ( ponzi / deficit financing )
    uint256[2] public inflationRatePerSec;
    /// [rate, lastSettled]
    address[2] private ownerStore;

    IERC20 public BaseToken;
    IMemberRegistry iMR;

    DAO20 internalToken;

    uint256 public baseID;
    uint256 localID;

    constructor(address BaseToken_, address owner_, address MemberRegistry_) {
        BaseToken = IERC20(BaseToken_);
        baseID = uint160(bytes20(address(this)));
        ownerStore = [owner_, owner_];
        iMR = IMemberRegistry(MemberRegistry_);
        internalToken = new DAO20(BaseToken_, string(abi.encodePacked(address(this))), "Odao",18);
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
    error TransferFailed();

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
    function wrapMint(address to_, uint256 amount_) public returns (bool s) {
        if (!BaseToken.transferFrom(to_, ownerStore[1], amount_)) revert TransferFailed();
        s = internalToken.wrapMint(to_, amount_);
        require(s);
    }

    function unwrapBurn(address from_, uint256 amount_) public returns (bool s) {
        if (!internalToken.unwrapBurn(from_, amount_)) revert TransferFailed();

        s = BaseToken.transfer(from_, amount_);
        require(s);
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
        localID = localID * baseID;
        emit LocalIncrement(localID);
    }

    /*//////////////////////////////////////////////////////////////
                                 VIEW
    //////////////////////////////////////////////////////////////*/

    function owner() public view returns (address) {
        return ownerStore[1];
    }
}
