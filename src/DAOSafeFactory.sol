// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interfaces/IMember1155.sol";
import "./interfaces/IoDAO.sol";
import "./interfaces/iInstanceDAO.sol";
import "./interfaces/IMembrane.sol";
import "./interfaces/ITokenFactory.sol";
import "./utils/Address.sol";
import "./interfaces/IDAO20.sol";

import {IGSafe} from "./interfaces/IGSafe.sol";
import {SafeEndpoint} from "./SafeEndpoint.sol";

import "./errors.sol";

/// @author BPA, parseb
///
contract DAOSafeFactory {
    IMemberRegistry iMR;
    address ODAOaddr;

    constructor() {
        iMR = IMemberRegistry(msg.sender);
    }

    function _setInitODAOAddr() external {
        require(ODAOaddr == address(0));
        ODAOaddr = iMR.ODAOaddress();
    }

    function createSafeL2(address forParent_) external returns (address newSafe) {
        require(msg.sender == ODAOaddr);
        newSafe = address(new SafeEndpoint(forParent_, address(iMR)));
    }
}
