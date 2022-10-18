// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "./interfaces/IMember1155.sol";

contract DAOinstance {
    IERC20 public BaseToken;
    address[2] private ownerStore;
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

    /*//////////////////////////////////////////////////////////////
                                 external
    //////////////////////////////////////////////////////////////*/

    // require(msg.sender == owner(), "Only Owner");

    function proposeStateChange() public returns (bool) {}

    /// @notice ownership change function. execute twice
    function giveOwnership(address newOwner_) external returns (address currentOwner) {
        require(msg.sender == ownerStore[1], "Unauthorized");
        ownerStore = ownerStore[0] == newOwner_ ? [newOwner_, newOwner_] : [newOwner_, msg.sender];
    }

    /// @notice takes the basetoken of this
    function wrapMint(address baseToken_, uint256 amount_, address to_) public returns (bool s) {
        BaseToken.transferFrom(msg.sender, address(this), amount_);
        s = s && iMR._wrapMint(address(BaseToken), amount_, to_);
    }

    function unwrapBurn(address baseToken_, uint256 amount_, address from_) public returns (bool s) {
        iMR._unwrapBurn(from_, amount_, address(BaseToken));
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
