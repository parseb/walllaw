// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interfaces/IMember1155.sol";
import "./interfaces/IoDAO.sol";
import "./interfaces/iInstanceDAO.sol";
import "./interfaces/IMembrane.sol";

import "./utils/Address.sol";
import "./errors.sol";

import "safe-contracts/SafeL2.sol";

/// @author BPA, parseb
contract SafeEndpoint is SafeL2 {
    address public parentAddress;
    iInstanceDAO parentDAO;
    IMemberRegistry MR;

    constructor(address masterInstance_, address MRaddr) {
        parentAddress = masterInstance_;
        parentDAO = iInstanceDAO(masterInstance_);
        MR = IMemberRegistry(MRaddr);
    }

    error SafeEnd__Unauthorized(address culprit);

    modifier onlyParent() {
        if (msg.sender != parentAddress) revert SafeEnd__Unauthorized(msg.sender);
        _;
    }

    /// @notice Adds provided to owner list if is member of parent.
    function addOwner(address who_) external returns (bool) {
        require(!isOwner(who_), "GS204");
        _updateThreshold();
        if (parentDAO.isMember(who_)) addOwnerWithThreshold(who_, threshold);
        return isOwner(who_);
    }

    /// @notice Parent call to remove owner from list if no longer member.
    function removeOwner(address who_) external returns (bool) {
        require(isOwner(who_), "GS205");
        if (!parentDAO.isMember(who_)) removeOwner(_getPrevOwner(who_), who_, threshold);
        _updateThreshold();
        return !isOwner(who_);
    }

    /////////// private #############
    /////////////////////////////////

    function _getPrevOwner(address whom_) private returns (address prevO) {
        prevO = SENTINEL_OWNERS;
        while (owners[prevO] != whom_) prevO = owners[prevO];
    }

    function _updateThreshold() private {
        threshold = MR.howManyTotal(uint160(parentAddress)) / 2 + 1;
    }
}
