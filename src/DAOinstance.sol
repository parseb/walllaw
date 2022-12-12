// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IMember1155.sol";
import "./interfaces/IoDAO.sol";
import "./interfaces/iInstanceDAO.sol";
import "./utils/Address.sol";
import "./DAO20.sol";
import "./errors.sol";


////DEEV
import "forge-std/console.sol";


contract DAOinstance {
    uint256 public baseID;
    uint256 public baseInflationRate;
    uint256 public baseInflationPerSec;
    uint256 public localID;
    uint256 public instantiatedAt;
    address ODAO;
    address public parentDAO;
    address[2] private ownerStore;
    IERC20 public BaseToken;
    IMemberRegistry iMR;
    DAO20 public internalToken;

    /// # EOA => subunit => [percentage, amt]
    mapping(address => mapping(address => uint256[2])) userSignal;

    /// #subunit id => [perSecond, timestamp]
    mapping(address => uint256[2]) subunitPerSec;

    /// last user distributive signal
    mapping(address => uint256[]) redistributiveSignal;

    /// expressed: id/percent/uri | msgSender()/address(0) | value/0
    mapping(uint256 => mapping(address => uint256)) public expressed;

    /// list of expressors for id/percent/uri
    mapping(uint256 => address[]) expressors;


    //// DEV
    uint256  timesCalled;

    constructor(address BaseToken_, address owner_, address MemberRegistry_) {
        ODAO = msg.sender;
        instantiatedAt = block.timestamp;
        BaseToken = IERC20(BaseToken_);
        baseID = uint160(bytes20(address(this)));
        baseInflationRate = baseID % 100 > 0 ? baseID % 100 : 1;
        localID = 1;
        ownerStore = [owner_, owner_];
        iMR = IMemberRegistry(MemberRegistry_);
        internalToken = new DAO20(BaseToken_, string(abi.encodePacked(address(this))), "Odao",18);
        subunitPerSec[address(this)][1] = block.timestamp;

        emit NewInstance(address(this), BaseToken_, owner_);
    }

    /*//////////////////////////////////////////////////////////////
                                 events
    //////////////////////////////////////////////////////////////*/

    event LocalIncrement(uint256 localID);
    event StateAdjusted();
    event AdjustedRate();
    event UserPreferedGuidance();
    event GlobalInflationUpdated(uint256 RatePerYear, uint256 perSecInflation);
    event inflationaryMint(uint256 amount);
    event gCheckKick(address indexed who);
    event NewInstance(address indexed at, address indexed baseToken, address owner);

    /*//////////////////////////////////////////////////////////////
                                 modifiers
    //////////////////////////////////////////////////////////////*/

    modifier onlyOwner() {
        if (!(msg.sender == ownerStore[1] || msg.sender == ODAO)) revert DAOinstance__NotOwner();
        _;
    }

    modifier onlyMember() {
        if (!isMember(_msgSender())) revert DAOinstance__NotMember();
        _;
    }

    modifier onlyEndpoint() {
        if (iMR.howManyTotal(baseID) > 1) revert DAOinstance__NotEndpoint1();
        if (iMR.balanceOf(msg.sender, baseID) == 1) revert DAOinstance__NotEndpoint2();
        _;
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
            : IoDAO(ODAO).inUseMembraneId(address(this));
    }

    //// @security with great power comes the need of great awareness
    function executeExternalLogic(uint256 callId_) external onlyMember returns (bool) {
        _expressPreference(callId_);

        callId_ = ((internalToken.totalSupply() / (expressed[callId_][address(0)] + 1) <= 2))
            ? _majoritarianUpdate(callId_)
            : 0;

        return callId_ > 0;
    }

    /// for un-delayed execution todo
    function whitelistCall(uint256 callId_) external onlyOwner returns (uint256 oneTwo) {}

    function changeUri(bytes32 uri_) external onlyMember returns (bytes32 currentUri) {
        if (uint256(uri_) < 101 || IoDAO(ODAO).isMembrane(uint256(uri_))) revert DAOinstance__YouCantDoThat();
        _expressPreference(uint256(uri_));

        currentUri = (internalToken.totalSupply() / (expressed[uint256(uri_)][address(0)] + 1) <= 2)
            ? bytes32(_majoritarianUpdate(uint256(uri_)))
            : bytes32(abi.encode(iMR.uri(baseID)));
    }

    /// @dev max length and sum of cronoOrderedDistributionAmts is 100
    function distributiveSignal(uint256[] memory cronoOrderedDistributionAmts) external onlyMember returns (uint i) {
        uint256 senderForce = internalToken.balanceOf(_msgSender());
        if (senderForce == 0) revert DAOinstance__HasNoSay();
        redistributiveSignal[_msgSender()] = cronoOrderedDistributionAmts;
        /// cronoOrderedDistributionAmts
        address[] memory subDAOs = IoDAO(ODAO).getDAOsOfToken(internalTokenAddress());
        if (subDAOs.length != cronoOrderedDistributionAmts.length) revert DAOinstance__LenMismatch();

        uint256 centum;
        uint256 perSec;
        for (i; i < subDAOs.length;) {

            redistributeSubDAO(subDAOs[i]);

            uint256 submittedValue = cronoOrderedDistributionAmts[i];
            if (subunitPerSec[subDAOs[i]][1] == 0) {
                subunitPerSec[subDAOs[i]][1] = iInstanceDAO(subDAOs[i]).initiatedAt();
            }
            if (submittedValue == subunitPerSec[subDAOs[i]][0]) continue;

            address entity = subDAOs[i];
            // uint256 prevValue = subunitPerSec[entity][0];

            unchecked {
                centum += cronoOrderedDistributionAmts[i];
            }
            if (centum > 100) revert DAOinstance__Over100();

            perSec = submittedValue * baseInflationPerSec / 100;
            perSec = (senderForce * 100 / internalToken.totalSupply()) * perSec / 100; /// @dev senderForce < 1% 

            subunitPerSec[entity][0] = (subunitPerSec[entity][0] - userSignal[_msgSender()][entity][1]) + perSec;
            /// @dev fuzz  (subunitPerSec[entity][0] > userSignal[_msgSender()][entity][1])

            userSignal[_msgSender()][entity][1] = perSec;
            userSignal[_msgSender()][entity][0] = submittedValue;

            unchecked {
                ++i;
            }
        }
    }

    /// @notice rollsback last user preference signal proportional to withdrawn amount
    function rollbackInfluence(address ofWhom_, uint256 amnt_) private {}


    function unwrapBurn(uint256 amount_) public returns (bool s) {
        // rollbackInfluence(msg.sender, amount_);

        // if (!internalToken.transferFrom(msg.sender, address(this), amount_)) revert DAOinstance__TransferFailed();
        // internalToken
        // // = BaseToken.transfer(msg.sender, amount_);
        // s = BaseToken.transferFrom([1], msg.sender, amount_);

        // // _balanceReWeigh(amount_);
        // /// @dev q: shoudl unwrapping be tied to exit module
        // require(s);
    }

    function feedMe() external returns (uint256 fed) {
        address[] memory feedPath = IoDAO(ODAO).getTrickleDownPath(address(this));
        if (feedPath[0] == address(0))  {
            return fed = iInstanceDAO(parentDAO).redistributeSubDAO(address(this)); 
        }

        uint i = 1;
        for (i; i < feedPath.length;) {
            if (feedPath[i] == address(0)) break;
            iInstanceDAO(feedPath[i]).redistributeSubDAO(feedPath[i-1]);

            unchecked { ++ i;}
        }
        fed = iInstanceDAO(feedPath[0]).redistributeSubDAO(address(this)); 
    }

   

    function mintMembershipToken(address to_) external returns (bool s) {
        s = checkG(to_);
        if (!s) revert DAOinstance__Unqualified();
        s = iMR.makeMember(to_, baseID) && s;
    }

    //// @notice burns membership token of check entity if ineligible
    /// @param who_ checked address
    function gCheck(address who_) external returns (bool s) {
        if (iMR.balanceOf(who_, baseID) == 0) return false;
        s = checkG(who_);
        if (s) return true;
        if (!s) iMR.gCheckBurn(who_);

        s = _liquidateValue(who_);
        // if ( ! s) revert DAOinstance__CannotLiquidate();

        emit gCheckKick(who_);
    }

    /// @notice ownership change function. execute twice
    function giveOwnership(address newOwner_) external onlyOwner returns (address) {
        if (msg.sender == ODAO) ownerStore[0] = newOwner_;
        address prevOwner = ownerStore[1];

        ownerStore = ownerStore[0] == newOwner_ ? [newOwner_, newOwner_] : [newOwner_, msg.sender];

        /// @notice if ownership has changed
        if (msg.sender != ODAO && ownerStore[1] != prevOwner) {
            bool s = BaseToken.transferFrom(prevOwner, ownerStore[1], BaseToken.balanceOf(prevOwner));
            if (!s) revert DAOinstance__Unqualified();
        }
        return ownerStore[1];
    }

    function memberOnCreate() external returns (bool) {
        if (msg.sender != ODAO) revert DAOinstance__OnlyODAO();
        return iMR.makeMember(owner(), baseID);
    }

    function _majoritarianUpdate(uint256 newVal_) private returns (uint256 newVal) {
        if (msg.sig == this.mintInflation.selector) {
            baseInflationPerSec = internalToken.totalSupply() * baseInflationRate / 365 days / 100;
            // subunitPerSec[address(this)][0] = baseInflationPerSec;
        }

        if (msg.sig == this.signalInflation.selector) {
            baseInflationRate = newVal_;
            baseInflationPerSec = internalToken.totalSupply() * newVal_ / 365 days / 100;
            // subunitPerSec[address(this)][0] = baseInflationPerSec;
            return _postMajorityCleanup(newVal_);
        }

        if (msg.sig == this.changeMembrane.selector) {
            require(IoDAO(ODAO).setMembrane(address(this), newVal_), "f O.setM.");
            return _postMajorityCleanup(newVal_);
        }

        if (msg.sig == this.changeUri.selector) {
            iMR.setUri(bytes32(newVal_));
            return _postMajorityCleanup(newVal_);
        }

        if (msg.sig == this.executeExternalLogic.selector) {
            bool s;
            ExternallCall memory ExT = IoDAO(ODAO).prepLongDistanceCall(newVal_);
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

    function redistributeSubDAO(address subDAO_) public returns (uint256 gotAmt ) {
        mintInflation();
        gotAmt = subunitPerSec[subDAO_][0] * (block.timestamp - subunitPerSec[subDAO_][1]);
        subunitPerSec[subDAO_][1] = block.timestamp;
        if (! internalToken.transfer(subDAO_, gotAmt)) revert DAOinstance__itTransferFailed();
    }


    //////   @todo
    function _liquidateValue(address who_) private returns (bool s) {
        s = false;
        /// burn and withdraw up stair
    }

    function __initSetParentAddress(address parent_) external {
        if (parentDAO != address(0)) revert DAOinstance__alreadySet();
        parentDAO = parent_;
    }

    function incrementSubDAO() external returns (uint256) {
        require(msg.sender == ODAO, "root only");
        return _incrementID();
    }

    function _incrementID() private returns (uint256) {
        unchecked {
            ++localID;
        }
        emit LocalIncrement(localID);
        return localID;
    }

    function multicall(bytes[] calldata data) external returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }

    function _msgSender() private view returns (address) {
        ///
        return msg.sender;
    }

    /*//////////////////////////////////////////////////////////////
                                 VIEW
    //////////////////////////////////////////////////////////////*/

    function owner() public view returns (address) {
        return ownerStore[1];
    }

    function checkG(address _custard) public view returns (bool s) {
        Membrane memory M = IoDAO(ODAO).getInUseMembraneOfDAO(address(this));
        uint256 i;
        s = true;
        for (i; i < M.tokens.length;) {
            s = s && (IERC20(M.tokens[i]).balanceOf(_custard) >= M.balances[i]);
            unchecked {
                ++i;
            }
        }
    }

    function internalTokenAddress() public view returns (address) {
        return address(internalToken);
    }

    function baseTokenAddress() public view returns (address) {
        return address(BaseToken);
    }

    function getUserReDistribution(address user_) public view returns (uint256[] memory) {
        return redistributiveSignal[user_];
    }

    function initiatedAt() external view returns (uint256) {
        return instantiatedAt;
    }

    function isMember(address who_) public view returns (bool) {
        return (iMR.balanceOf(who_, baseID) > 0);
    }
}
