// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IMember1155.sol";
import "./interfaces/IoDAO.sol";
import "./interfaces/iInstanceDAO.sol";
import "./interfaces/IMembrane.sol";
import "./interfaces/ILongCall.sol";
import "./utils/Address.sol";
import "./DAO20.sol";
import "./errors.sol";

contract DAOinstance {
    uint256 public baseID;
    uint256 public baseInflationRate;
    uint256 public baseInflationPerSec;
    uint256 public instantiatedAt;
    address public parentDAO;
    address ODAO;
    IERC20 public BaseToken;
    DAO20 public internalToken;
    IMemberRegistry iMR;
    IMembrane iMB;
    ILongCall iLG;

    /// # EOA => subunit => [percentage, amt]
    mapping(address => mapping(address => uint256[2])) userSignal;

    /// #subunit id => [perSecond, timestamp]
    mapping(address => uint256[2]) subunitPerSec;

    /// last user distributive signal
    mapping(address => uint256[]) redistributiveSignal;

    /// expressed: id/percent/uri | msgSender()/address(0) | value/0
    mapping(uint256 => mapping(address => uint256)) expressed;

    /// list of expressors for id/percent/uri
    mapping(uint256 => address[]) expressors;

    constructor(address BaseToken_, address initiator_, address MemberRegistry_) {
        ODAO = msg.sender;
        instantiatedAt = block.timestamp;
        BaseToken = IERC20(BaseToken_);
        baseID = uint160(bytes20(address(this)));
        baseInflationRate = baseID % 100 > 0 ? baseID % 100 : 1;
        iMR = IMemberRegistry(MemberRegistry_);
        iMB = IMembrane(iMR.MembraneRegistryAddress());
        iLG = ILongCall(iMR.LongCallAddress());
        internalToken = new DAO20(BaseToken_, string(abi.encodePacked(address(this))), "Odao",18);
        BaseToken.approve(address(internalToken), type(uint256).max - 1);

        subunitPerSec[address(this)][1] = block.timestamp;

        emit NewInstance(address(this), BaseToken_, initiator_);
    }

    /*//////////////////////////////////////////////////////////////
                                 events
    //////////////////////////////////////////////////////////////*/

    event StateAdjusted();
    event AdjustedRate();
    event UserPreferedGuidance();
    event GlobalInflationUpdated(uint256 RatePerYear, uint256 perSecInflation);
    event inflationaryMint(uint256 amount);
    event NewInstance(address indexed at, address indexed baseToken, address owner);

    /*//////////////////////////////////////////////////////////////
                                 modifiers
    //////////////////////////////////////////////////////////////*/

    modifier onlyMember() {
        if (msg.sender == address(internalToken)) {
            _;
        } else {
            if (!isMember(_msgSender())) revert DAOinstance__NotMember();
            _;
        }
    }

    /// percentage anualized 1-100 as relative to the totalSupply of base token
    function signalInflation(uint256 percentagePerYear_) external onlyMember returns (uint256 inflationRate) {
        require(percentagePerYear_ <= 100, ">100!");
        _expressPreference(percentagePerYear_);

        inflationRate = (internalToken.totalSupply() / (expressed[percentagePerYear_][address(0)] + 1) <= 2)
            ? _majoritarianUpdate(percentagePerYear_)
            : baseInflationRate;
    }

    function changeMembrane(uint256 membraneId_) external onlyMember returns (uint256 membraneID) {
        _expressPreference(membraneId_);

        membraneID = ((internalToken.totalSupply() / (expressed[membraneId_][address(0)] + 1) <= 2))
            ? _majoritarianUpdate(membraneId_)
            : iMB.inUseMembraneId(address(this));
    }

    //// @security with great power comes the need of great awareness
    function executeExternalLogic(uint256 callId_) external onlyMember returns (bool) {
        _expressPreference(callId_);

        callId_ = ((internalToken.totalSupply() / (expressed[callId_][address(0)] + 1) <= 2))
            ? _majoritarianUpdate(callId_)
            : 0;

        return callId_ > 0;
    }

    function changeUri(bytes32 uri_) external onlyMember returns (bytes32 currentUri) {
        if (uint256(uri_) < 101 || iMB.isMembrane(uint256(uri_))) revert DAOinstance__YouCantDoThat();
        _expressPreference(uint256(uri_));

        currentUri = (internalToken.totalSupply() / (expressed[uint256(uri_)][address(0)] + 1) <= 2)
            ? bytes32(_majoritarianUpdate(uint256(uri_)))
            : bytes32(abi.encode(iMR.uri(baseID)));
    }

    function distributiveSignal(uint256[] memory cronoOrderedDistributionAmts)
        external
        onlyMember
        returns (uint256 i)
    {
        address sender = _msgSender();
        uint256 senderForce = internalToken.balanceOf(sender);
        if (senderForce == 0 && (!(cronoOrderedDistributionAmts.length == 0))) revert DAOinstance__HasNoSay();
        if (cronoOrderedDistributionAmts.length == 0) cronoOrderedDistributionAmts = redistributiveSignal[sender];
        redistributiveSignal[sender] = cronoOrderedDistributionAmts;

        address[] memory subDAOs = IoDAO(ODAO).getDAOsOfToken(address(internalToken));
        if (subDAOs.length != cronoOrderedDistributionAmts.length) revert DAOinstance__LenMismatch();

        uint256 centum;
        uint256 perSec;
        for (i; i < subDAOs.length;) {
            redistributeSubDAO(subDAOs[i]);

            uint256 submittedValue = cronoOrderedDistributionAmts[i];
            if (subunitPerSec[subDAOs[i]][1] == 0) {
                subunitPerSec[subDAOs[i]][1] = iInstanceDAO(subDAOs[i]).instantiatedAt();
            }
            if (submittedValue == subunitPerSec[subDAOs[i]][0]) continue;

            address entity = subDAOs[i];

            unchecked {
                centum += cronoOrderedDistributionAmts[i];
            }
            if (centum > 100) revert DAOinstance__Over100();

            perSec = submittedValue * baseInflationPerSec / 100;
            perSec = (senderForce * 1 ether / internalToken.totalSupply()) * perSec / 1 ether;
            /// @dev senderForce < 1%

            subunitPerSec[entity][0] = (subunitPerSec[entity][0] - userSignal[sender][entity][1]) + perSec;
            /// @dev fuzz  (subunitPerSec[entity][0] > userSignal[_msgSender()][entity][1])

            userSignal[sender][entity][1] = perSec;
            userSignal[sender][entity][0] = submittedValue;

            unchecked {
                ++i;
            }
        }
    }

    function feedMe() external returns (uint256 fed) {
        address[] memory feedPath = IoDAO(ODAO).getTrickleDownPath(address(this));
        if (feedPath[0] == address(0)) {
            return fed = iInstanceDAO(parentDAO).redistributeSubDAO(address(this));
        }

        uint256 i = 1;
        for (i; i < feedPath.length;) {
            if (feedPath[i] == address(0)) break;
            iInstanceDAO(feedPath[i]).redistributeSubDAO(feedPath[i - 1]);

            unchecked {
                ++i;
            }
        }
        fed = iInstanceDAO(feedPath[0]).redistributeSubDAO(address(this));
    }

    function mintMembershipToken(address to_) external returns (bool s) {
        if (msg.sender == ODAO) {
            parentDAO = IoDAO(ODAO).getParentDAO(address(this));
            if (internalToken.mintInitOne(to_)) return iMR.makeMember(to_, baseID);
        }

        s = iMB.checkG(to_, address(this));
        if (!s) revert DAOinstance__Unqualified();
        s = iMR.makeMember(to_, baseID) && s;
    }

    ///////////////////
    function _majoritarianUpdate(uint256 newVal_) private returns (uint256 newVal) {
        if (msg.sig == this.mintInflation.selector) {
            baseInflationPerSec = internalToken.totalSupply() * baseInflationRate / 365 days / 100;
        }

        if (msg.sig == this.signalInflation.selector) {
            baseInflationRate = newVal_;
            baseInflationPerSec = internalToken.totalSupply() * newVal_ / 365 days / 100;
            return _postMajorityCleanup(newVal_);
        }

        if (msg.sig == this.changeMembrane.selector) {
            require(iMB.setMembrane(newVal_, address(this)), "f O.setM.");
            return _postMajorityCleanup(newVal_);
        }

        if (msg.sig == this.changeUri.selector) {
            iMR.setUri(bytes32(newVal_));
            return _postMajorityCleanup(newVal_);
        }

        if (msg.sig == this.executeExternalLogic.selector) {
            bool s;
            ExternallCall memory ExT = iLG.prepLongDistanceCall(newVal_);
            if (ExT.eligibleCaller != msg.sender) revert DAOinstance__NotCallMaker();

            (s,) = address(ExT.callPointAddress).delegatecall(ExT.callData);

            newVal = s ? 1 : 0;
        }
    }

    function _expressPreference(uint256 preference_) private {
        uint256 pressure = internalToken.balanceOf(_msgSender());
        uint256 previous = expressed[preference_][_msgSender()];

        if (previous > 0) expressed[preference_][address(0)] -= previous;
        expressed[preference_][address(0)] += pressure;
        expressed[preference_][_msgSender()] = pressure;
        if (previous == 0) expressors[preference_].push(_msgSender());
    }

    function _postMajorityCleanup(uint256 target_) private returns (uint256 outcome) {
        /// is sum validatation superfluous and prone to error? -&/ gas concerns
        address[] memory agents = expressors[target_];
        uint256 sum = _postMajorityCleanup(agents, target_);

        if (!(sum >= expressed[target_][address(0)])) revert DAOinstance__CannotUpdate();

        delete expressed[target_][address(0)];
        delete expressors[target_];
        outcome = target_;
    }

    function _postMajorityCleanup(address[] memory agents, uint256 target_) public returns (uint256 outcome) {
        if (expressed[target_][address(0)] < (internalToken.totalSupply() / 2)) revert DAOinstance__notmajority();

        uint256 sum;
        address a;
        for (outcome; outcome < agents.length;) {
            a = agents[outcome];
            unchecked {
                sum += expressed[target_][a];
            }
            delete expressed[target_][a];
            unchecked {
                ++outcome;
            }
        }
        outcome = sum;
    }

    function mintInflation() public returns (uint256 amountToMint) {
        amountToMint = (block.timestamp - subunitPerSec[address(this)][1]);
        if (amountToMint == 0) return amountToMint;

        amountToMint = (amountToMint * baseInflationPerSec);
        require(internalToken.inflationaryMint(amountToMint));
        subunitPerSec[address(this)][1] = block.timestamp;
        _majoritarianUpdate(0);

        emit inflationaryMint(amountToMint);
    }

    function redistributeSubDAO(address subDAO_) public returns (uint256 gotAmt) {
        mintInflation();
        gotAmt = subunitPerSec[subDAO_][0] * (block.timestamp - subunitPerSec[subDAO_][1]);
        subunitPerSec[subDAO_][1] = block.timestamp;
        if (!internalToken.transfer(subDAO_, gotAmt)) revert DAOinstance__itTransferFailed();
    }

    function multicall(bytes[] calldata data) external returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }

    function _msgSender() private view returns (address) {
        if (msg.sender == address(internalToken)) return internalToken.burnInProgress();

        return msg.sender;
    }

    /*//////////////////////////////////////////////////////////////
                                 VIEW
    //////////////////////////////////////////////////////////////*/

    function internalTokenAddress() external view returns (address) {
        return address(internalToken);
    }

    function baseTokenAddress() external view returns (address) {
        return address(BaseToken);
    }

    function getUserReDistribution(address user_) external view returns (uint256[] memory) {
        return redistributiveSignal[user_];
    }

    function isMember(address who_) private view returns (bool) {
        return ((who_ == address(internalToken)) || iMR.balanceOf(who_, baseID) > 0);
    }

    function getUserSignal(address who_, address subUnit_) external view returns (uint256[2] memory) {
        return userSignal[who_][subUnit_];
    }

    function getILongDistanceAddress() external view returns (address) {
        return address(iLG);
    }
}
