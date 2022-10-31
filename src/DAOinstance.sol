// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "./interfaces/IMember1155.sol";
import "./interfaces/IoDAO.sol";
import "./DAO20.sol";

contract DAOinstance {
    uint256 public baseID;
    uint256 baseInflationRate;
    uint256 baseInflationPerSec;

    uint256 public localID;
    address public ODAO;
    address public unwrapper;

    mapping(address => uint256[][2]) userSignal; /// # EOA => [subUnitId, percentage]
    mapping(uint256 => uint256[2]) subunitShare; /// #subunit id => [percentage, timestamp] 

    mapping(uint256 => mapping(address => uint256)) cakeSlice; /// # endpoint

    /// @dev @security consider outsider influence asumming economic risk to temporarily change rate
    /// [address_of_sender(subjective) or address(0)(objective)] - sets internalInflation on majority consensus
    /// inflation is relative to 

    mapping(uint256 => mapping(address => uint256)) agentPreference;
    mapping(uint256 => address[]) expressedRatePreference;
    mapping(uint256 => address[]) expressedMembranePreference;


    address[2] private ownerStore;

    IERC20 public BaseToken;
    IMemberRegistry iMR;

    DAO20 public internalToken;

    constructor(address BaseToken_, address owner_, address MemberRegistry_) {
        ODAO = msg.sender;
        BaseToken = IERC20(BaseToken_);
        baseID = uint160(bytes20(address(this)));
        baseInflationRate = baseID % 100;
        localID = 1;
        ownerStore = [owner_, owner_];
        iMR = IMemberRegistry(MemberRegistry_);
        internalToken = new DAO20(BaseToken_, string(abi.encodePacked(address(this))), "Odao",18);
    }

    /*//////////////////////////////////////////////////////////////
                                 events
    //////////////////////////////////////////////////////////////*/

    event LocalIncrement(uint256 localID);
    event StateAdjusted();
    event AdjustedRate();
    event UserPreferedGuidance();
    event GlobalInflationUpdated(uint RatePerYear, uint perSecInflation);

    /*//////////////////////////////////////////////////////////////
                                 errors
    //////////////////////////////////////////////////////////////*/

    error DAOinstance__NotOwner();
    error DAOinstance__TransferFailed();
    error DAOinstance__Unqualified();
    error DAOinstance__NotMember();
    error DAOinstance__InvalidMembrane();
    error DAOinstance__CannotUpdate();

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


    /// percentage anualized 1-100 as relative to the totalSupply of base token
    function signalInflation(uint percentagePerYear_) external onlyMember returns (uint inflationRate) {
        
        require(percentagePerYear_ <= 100, ">100!");
        require(agentPreference[percentagePerYear_][msg.sender] == 0, "CannotUpdate");

        uint balance = IERC20(internalTokenAddr()).balanceOf(msg.sender);
        uint totalSupply = IERC20(address(internalToken)).totalSupply();

        agentPreference[percentagePerYear_][msg.sender] = balance;
        agentPreference[percentagePerYear_][address(0)] += balance;
        expressedRatePreference[percentagePerYear_].push(msg.sender);

        inflationRate = (totalSupply / agentPreference[percentagePerYear_][address(0)] <= 2) ? _updateGlobalInflation(totalSupply,percentagePerYear_) : baseInflationRate;

    }

    function changeMembrane(uint membraneId_) external onlyMember() returns (uint membraneID) {
        if (agentPreference[membraneId_][msg.sender] == 0) revert DAOinstance__CannotUpdate();
        
        Membrane memory M = IoDAO(ODAO).getMembrane(membraneId_);
        if (M.tokens.length == 0) revert DAOinstance__InvalidMembrane();

        uint balance = IERC20(internalTokenAddr()).balanceOf(msg.sender);
        uint totalSupply = IERC20(address(internalToken)).totalSupply();

        agentPreference[membraneId_][msg.sender] = balance;
        agentPreference[membraneId_][address(0)] += balance;
        expressedMembranePreference[membraneId_].push(msg.sender);
        
        require(IoDAO(ODAO).setMembrane(address(this), membraneId_));
        membraneID = (totalSupply / agentPreference[membraneId_][address(0)] <= 2) ? _updateMembrane(membraneId_) : IoDAO(ODAO).inUseMembraneId(address(this));
    }




    function distributiveSignal(uint256[] memory cronoOrderedDistribution) external onlyMember() returns (bool s) {
        s = _redistribute();

        IoDAO(ODAO).getSubDAOsOf(address(BaseToken));

    }



    /// @dev @todo: @security review token wrap
    function wrapMint(uint256 amount_) public returns (bool s) {
        if (!BaseToken.transferFrom(msg.sender, ownerStore[1], amount_)) revert DAOinstance__TransferFailed();
        s = internalToken.wrapMint(msg.sender, amount_);

        // _balanceReWeigh(amount_);
        require(s);
        
    }

    function unwrapBurn(uint256 amount_) public returns (bool s) {
        if (!internalToken.unwrapBurn(msg.sender, amount_)) revert DAOinstance__TransferFailed();

        s = BaseToken.transfer(msg.sender, amount_);

        // _balanceReWeigh(amount_);
        require(s);
    }

    function mintMembershipToken(address to_) external returns (bool s) {
        Membrane memory M = IoDAO(ODAO).getInUseMembraneOfDAO(address(this));

        uint256 i;
        s = true;
        for (i; i < M.tokens.length;) {
            s = s && (IERC20(M.tokens[i]).balanceOf(to_) >= M.balances[i]);
            unchecked { ++ i; }
        }

        if (! s) revert DAOinstance__Unqualified();
        s = iMR.makeMember(to_, baseID) && s;

    }

        /// @notice ownership change function. execute twice
    function giveOwnership(address newOwner_) external onlyOwner returns (address) {
        if (msg.sender == ODAO) ownerStore[0] = newOwner_;
        ownerStore = ownerStore[0] == newOwner_ ? [newOwner_, newOwner_] : [newOwner_, msg.sender];
        return ownerStore[1];
    }

    /*//////////////////////////////////////////////////////////////
                                 privat
    //////////////////////////////////////////////////////////////*/

    function _updateGlobalInflation(uint totalSupply_, uint newRate_) private returns (uint inflation) {
        _redistribute();

        /// 

        baseInflationRate = newRate_;
        baseInflationPerSec = totalSupply_ * newRate_ / 31449600 / 100;
        
        for( inflation; inflation < expressedRatePreference[newRate_].length;) {
            delete agentPreference[newRate_][expressedRatePreference[newRate_][inflation]];
            unchecked { ++ inflation;}
        }
            delete agentPreference[newRate_][address(0)];
            delete expressedRatePreference[newRate_];

        inflation = newRate_;

        emit GlobalInflationUpdated(newRate_, baseInflationPerSec );
    }

    function _updateMembrane(uint id) private returns (uint256 newId) {
        _redistribute();

        
        for( newId; newId < expressedMembranePreference[id].length;) {
            delete agentPreference[id][expressedMembranePreference[id][newId]];
            unchecked { ++ newId;}
        }
            delete agentPreference[id][address(0)];
            delete expressedMembranePreference[id];

        require(IoDAO(ODAO).setMembrane(address(this), id));
        emit GlobalInflationUpdated(id, baseInflationPerSec );

        newId = id;
    }

    function _redistribute() private returns (bool) {
        /// set internal token allowance to owner - subdao
        /// 

        /// update inflation

        /// iterate and allow to subdaos
    }

    // function _balanceReWeigh(uint256 amount) private {
    //     uint256[][2] memory uSignal = userSignal[msg.sender];
    //     //uint len = uSignal.length;
    //     uint256 i;
    //     for (i; i < uSignal.length;) {
    //         // if (msg.sig == this.wrapMint.selector ) subunitShare[uSignal[i][0]][1] = _mint(1);
    //         // if (msg.sig == this.unwrapBurn.selector ) subunitShare[uSignal[i][0]][1] = _mint(1);

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

    function getUserReDistribution() public view returns (uint[] memory allocation) {

    }
}
