// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "./interfaces/IERC20.sol";
import "./interfaces/IMember1155.sol";
import "./interfaces/IoDAO.sol";
import "./utils/Address.sol";
import "./DAO20.sol";

contract DAOinstance {
    uint256 public baseID;

    uint256 public baseInflationRate;
    uint256 public baseInflationPerSec;
    uint256 public localID;

    address public ODAO;

    mapping(address => mapping(address => uint256[2])) userSignal;

    /// # EOA => subunit => [percentage, amt]

    mapping(address => uint256[2]) subunitPerSec;

    /// #subunit id => [perSecond, timestamp]

    mapping(uint256 => mapping(address => uint256)) cakeSlice;

    /// # endpoint

    /// @dev @security consider outsider influence asumming economic risk to temporarily change rate
    /// [address_of_sender(subjective) or address(0)(objective)] - sets internalInflation on majority consensus
    /// inflation is relative to

    mapping(uint256 => mapping(address => uint256)) agentPreference;
    mapping(address => uint256[2]) lastAgentExpressedPreference; //[interestRate,membraneId]
    mapping(uint256 => address[]) expressedRatePreference;
    mapping(uint256 => address[]) expressedMembranePreference;

    address[2] private ownerStore;

    IERC20 public BaseToken;
    IMemberRegistry iMR;
    DAO20 public internalToken;
    uint256 public instantiatedAt;

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
                                 errors
    //////////////////////////////////////////////////////////////*/

    error DAOinstance__NotOwner();
    error DAOinstance__TransferFailed();
    error DAOinstance__Unqualified();
    error DAOinstance__NotMember();
    error DAOinstance__InvalidMembrane();
    error DAOinstance__CannotUpdate();
    error DAOinstance__LenMismatch();
    error DAOinstance__Over100();
    error DAOinstance__nonR();
    error DAOinstance__NotEndpoint();
    error DAOinstance__OnlyODAO();

    /*//////////////////////////////////////////////////////////////
                                 modifiers
    //////////////////////////////////////////////////////////////*/

    modifier onlyOwner() {
        if (msg.sender != ownerStore[1] && msg.sender != ODAO) revert DAOinstance__NotOwner();
        _;
    }

    modifier onlyMember() {
        if (iMR.balanceOf(msg.sender, baseID) == 0) revert DAOinstance__NotMember();
        _;
    }

    modifier onlyEndpoint() {
        if (iMR.howManyTotal(baseID) > 1) revert DAOinstance__NotEndpoint();
        _;
    }

    /// percentage anualized 1-100 as relative to the totalSupply of base token
    function signalInflation(uint256 percentagePerYear_) external onlyMember returns (uint256 inflationRate) {
        require(percentagePerYear_ <= 100, ">100!");
        require(agentPreference[percentagePerYear_][_msgSender()] == 0, "CannotUpdate");

        /// once signaled cannot be changed (simplicity, for now) - swap possible
        // require(lastAgentExpressedPreference[_msgSender()][0] == 0, "CannotUpdate");

        uint256 balance = IERC20(internalTokenAddr()).balanceOf(_msgSender());
        uint256 totalSupply = internalToken.totalSupply();

        agentPreference[percentagePerYear_][msg.sender] = balance;
        agentPreference[percentagePerYear_][address(0)] += balance;
        expressedRatePreference[percentagePerYear_].push(_msgSender());
        lastAgentExpressedPreference[_msgSender()][0] = percentagePerYear_;

        inflationRate = (totalSupply / agentPreference[percentagePerYear_][address(0)] <= 2)
            ? _updateGlobalInflation(totalSupply, percentagePerYear_)
            : baseInflationRate;
    }

    function changeMembrane(uint256 membraneId_) external onlyMember returns (uint256 membraneID) {
        // if (agentPreference[membraneId_][msg.sender] == 0) revert DAOinstance__CannotUpdate();

        /// once signaled cannot be changed (simplicity, for now) - swap possible
        // require(lastAgentExpressedPreference[_msgSender()][1] == 0, "CannotUpdate");

        Membrane memory M = IoDAO(ODAO).getMembrane(membraneId_);
        if (M.tokens.length == 0) revert DAOinstance__InvalidMembrane();

        uint256 balance = internalToken.balanceOf(msg.sender);
        uint256 totalSupply = internalToken.totalSupply();

        agentPreference[membraneId_][msg.sender] = balance;
        agentPreference[membraneId_][address(0)] += balance;
        expressedMembranePreference[membraneId_].push(msg.sender);
        lastAgentExpressedPreference[_msgSender()][1] = membraneId_;

        membraneID = ((totalSupply / (agentPreference[membraneId_][address(0)] + 1) <= 2))
            ? _updateMembrane(membraneId_)
            : IoDAO(ODAO).inUseMembraneId(address(this));
    }


    /// @dev max length of cronoOrderedDistributionAmts is 100
    function distributiveSignal(uint256[] memory cronoOrderedDistributionAmts) external onlyMember returns (bool s) {
        s = _redistribute();
        /// cronoOrderedDistributionAmts
        address[] memory subDAOs = IoDAO(ODAO).getSubDAOsOf(internalTokenAddr());
        if (subDAOs.length != cronoOrderedDistributionAmts.length) revert DAOinstance__LenMismatch();

        // mapping(address => mapping(address => uint256[2])) userSignal; /// # EOA => subunit => [ percentage, amt]
        // mapping(address => uint256[2]) subunitPerSec; /// #subunit id => [perSecond, timestamp]

        uint256 i;
        uint256 centum;
        uint256 perSec;
        for (i; i < subDAOs.length;) {
            uint256 submittedValue = cronoOrderedDistributionAmts[i];
            if (submittedValue == subunitPerSec[subDAOs[i]][0]) continue;

            address entity = subDAOs[i];
            uint256 prevValue = subunitPerSec[entity][0];
            uint256 senderForce = IERC20(internalTokenAddr()).balanceOf(_msgSender());

            unchecked {
                centum += cronoOrderedDistributionAmts[i];
            }
            if (centum > 100) revert DAOinstance__Over100();

            perSec = submittedValue * baseInflationPerSec / 100;
            perSec = ( senderForce * 100 / internalToken.totalSupply() ) * perSec / 100;

            subunitPerSec[entity][0] = (subunitPerSec[entity][0] - userSignal[_msgSender()][entity][1]) + perSec;

            /// @dev fuzz
            userSignal[_msgSender()][entity][1] = perSec;
            userSignal[_msgSender()][entity][0] = submittedValue;

            unchecked {
                ++i;
            }
        }
    }

    /// @dev reconsider
    /// @notice rollsback last user preference signal proportional to withdrawn amount
    function rollbackInfluence(address ofWhom_, uint256 amnt_) private {
        if ((lastAgentExpressedPreference[ofWhom_][0] + lastAgentExpressedPreference[ofWhom_][1]) == 0) return;

        uint256 cache = agentPreference[lastAgentExpressedPreference[ofWhom_][0]][ofWhom_];
        if (cache > 0) {
            unchecked {
                agentPreference[lastAgentExpressedPreference[ofWhom_][0]][ofWhom_] -= amnt_;
            }
        }
        if (agentPreference[lastAgentExpressedPreference[ofWhom_][0]][ofWhom_] > cache) {
            lastAgentExpressedPreference[ofWhom_][0] = 0;
        }

        cache = lastAgentExpressedPreference[ofWhom_][1];
        if (cache > 0) {
            unchecked {
                agentPreference[lastAgentExpressedPreference[ofWhom_][0]][ofWhom_] -= amnt_;
            }
        }
        if (agentPreference[lastAgentExpressedPreference[ofWhom_][0]][ofWhom_] > cache) {
            lastAgentExpressedPreference[ofWhom_][0] = 0;
        }
    }

    /// @dev @todo: @security review token wrap
    function wrapMint(uint256 amount_) public returns (bool s) {
        if (!BaseToken.transferFrom(msg.sender, ownerStore[1], amount_)) revert DAOinstance__TransferFailed();
        s = internalToken.wrapMint(msg.sender, amount_);

        // _balanceReWeigh(amount_);
        require(s);
    }

    function unwrapBurn(uint256 amount_) public returns (bool s) {
        rollbackInfluence(msg.sender, amount_);

        if (!internalToken.unwrapBurn(msg.sender, amount_)) revert DAOinstance__TransferFailed();

        // = BaseToken.transfer(msg.sender, amount_);
        s = BaseToken.transferFrom(ownerStore[1], msg.sender, amount_);

        // _balanceReWeigh(amount_);
        /// @dev q: shoudl unwrapping be tied to exit module
        require(s);
    }

    function mintMembershipToken(address to_) external returns (bool s) {
        s = _checkG(to_);
        if (!s) revert DAOinstance__Unqualified();
        s = iMR.makeMember(to_, baseID) && s;
    }

    //// @notice burns membership token of check entity if ineligible
    /// @param who_ checked address
    function gCheck(address who_) external returns (bool s) {
        if (iMR.balanceOf(who_, baseID) == 0) return false;
        s = _checkG(who_);
        if (s) return true;
        if (!s) iMR.gCheckBurn(who_);
        emit gCheckKick(who_);
    }

    function _checkG(address _custard) private returns (bool s) {
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
    /// @notice ownership change function. execute twice

    function giveOwnership(address newOwner_) external onlyOwner returns (address) {
        if (msg.sender == ODAO) ownerStore[0] = newOwner_;
        address prevOwner = ownerStore[1];

        ownerStore = ownerStore[0] == newOwner_ ? [newOwner_, newOwner_] : [newOwner_, msg.sender];

        if (msg.sender != ODAO && ownerStore[1] != prevOwner) {
            bool s = BaseToken.transferFrom(prevOwner, ownerStore[1], BaseToken.balanceOf(prevOwner));
            if (!s) revert DAOinstance__Unqualified();
        }
        return ownerStore[1];
    }

    function makeOwnerMemberOnCreateForEndpointFunctionality() external returns (bool) {
        if (msg.sender != ODAO) revert DAOinstance__OnlyODAO();
        return iMR.makeMember(owner(), baseID);
    }

    /*//////////////////////////////////////////////////////////////
                                 privat
    //////////////////////////////////////////////////////////////*/

    function _updateGlobalInflation(uint256 totalSupply_, uint256 newRate_) private returns (uint256 inflation) {
        // _redistribute();

        baseInflationRate = newRate_;
        baseInflationPerSec = totalSupply_ * newRate_ / 31449600 / 100;

        subunitPerSec[address(this)][0] = baseInflationPerSec;

        for (inflation; inflation < expressedRatePreference[newRate_].length;) {
            delete agentPreference[newRate_][expressedRatePreference[newRate_][inflation]];

            delete lastAgentExpressedPreference[expressedRatePreference[newRate_][inflation]][0];
            unchecked {
                ++inflation;
            }
        }
        delete agentPreference[newRate_][address(0)];
        delete expressedRatePreference[newRate_];

        inflation = newRate_;

        emit GlobalInflationUpdated(newRate_, baseInflationPerSec);
    }

    function _updateMembrane(uint256 id) private returns (uint256 newId) {
        //_redistribute();
        // _unroll();

        for (newId; newId < expressedMembranePreference[id].length;) {
            delete agentPreference[id][expressedMembranePreference[id][newId]];

            delete lastAgentExpressedPreference[expressedMembranePreference[id][newId]][1];
            unchecked {
                ++newId;
            }
        }
        delete agentPreference[id][address(0)];
        delete expressedMembranePreference[id];

        require(IoDAO(ODAO).setMembrane(address(this), id));
        emit GlobalInflationUpdated(id, baseInflationPerSec);

        newId = id;
    }

    function mintInflation() public returns (uint256 amountToMint) {
        if (subunitPerSec[address(this)][1] == block.timestamp) revert DAOinstance__nonR();

        amountToMint = ((block.timestamp - subunitPerSec[address(this)][1]) * subunitPerSec[address(this)][0]);
        require(internalToken.inflationaryMint(amountToMint));
        subunitPerSec[address(this)][1] = block.timestamp;

        emit inflationaryMint(amountToMint);
    }

    function redistributeSubDAO(address subDAO_) public returns (bool s) {
        _redistribute();
        uint256 amt = subunitPerSec[subDAO_][0] * (block.timestamp - subunitPerSec[subDAO_][1]);

        internalToken.transfer(subDAO_, amt);
        subunitPerSec[subDAO_][1] = block.timestamp;
    }

    function _redistribute() private returns (bool) {
        /// set internal token allowance to owner - subdao
        ///

        /// update inflation
        mintInflation();

        /// iterate and allow to subdaos
    }

    // function _balanceReWeigh(uint256 amount) private {
    //     uint256[][2] memory uSignal = userSignal[msg.sender];
    //     //uint len = uSignal.length;
    //     uint256 i;
    //     for (i; i < uSignal.length;) {
    //         // if (msg.sig == this.wrapMint.selector ) subunitPerSec[uSignal[i][0]][1] = _mint(1);
    //         // if (msg.sig == this.unwrapBurn.selector ) subunitPerSec[uSignal[i][0]][1] = _mint(1);

    //         unchecked {
    //             ++i;
    //         }
    //     }
    // }

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

    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }

    function _msgSender() private returns (address) {
        ///
        return msg.sender;
    }



    /*//////////////////////////////////////////////////////////////
                                 VIEW
    //////////////////////////////////////////////////////////////*/

    function owner() public view returns (address) {
        return ownerStore[1];
    }

    function internalTokenAddr() public view returns (address) {
        return address(internalToken);
    }

    function baseTokenAddress() public view returns (address) {
        return address(BaseToken);
    }

    function getParent() public view returns (address) {
        return IoDAO(ODAO).getParentDAO(address(this));
    }

    function getUserReDistribution() public view returns (uint256[] memory allocation) {}
}
