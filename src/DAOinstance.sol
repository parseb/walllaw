// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";

contract DAOinstance {
    IERC20 public BaseToken;
    address[2] private ownerStore;

    uint256 public baseID;
    uint256 localID;

    struct Membrane {
        address[] tokens;
        uint256[] balances;
        bytes meta;
    }

    mapping(uint256 => Membrane) getMembraneById;

    constructor(address baseToken_, address owner_) {
        BaseToken = IERC20(baseToken_);
        baseID = uint160(bytes20(address(this)));
        ownerStore = [owner_, owner_];
    }

    /*//////////////////////////////////////////////////////////////
                                 events
    //////////////////////////////////////////////////////////////*/

    event LocalIncrement(uint256 localID);
    event subSetCreated(uint256 subUnitId, uint256 parentUnitId);

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

    function entityData(uint256 id) external view returns (bytes memory) {
        return getMembraneById[id].meta;
    }
}
