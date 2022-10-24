// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "./interfaces/IMember1155.sol";
import "./interfaces/IoDAO.sol";
import "./DAO20.sol";

contract DAOinstance {
    uint256 public baseID;
    uint256 public localID;
    address public ODAO;
    address public unwrapper;
    /// inflation rate per sec for base wrapped token ( ponzi / deficit financing )
    uint256[2] public inflationRateLastUse;
    /// [rate, lastSettled]

    /// [user][entityId] = [ 5 / 1000]
    mapping(address => uint256[][2]) userSignal;
    mapping(uint256 => uint256[2]) subunitShare;

    address[2] private ownerStore;
    uint256[] public subUnits;

    IERC20 public BaseToken;
    IMemberRegistry iMR;

    DAO20 public internalToken;

    constructor(address BaseToken_, address owner_, address MemberRegistry_) {
        ODAO = msg.sender;
        BaseToken = IERC20(BaseToken_);
        baseID = uint160(bytes20(address(this)));
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

    /*//////////////////////////////////////////////////////////////
                                 errors
    //////////////////////////////////////////////////////////////*/

    error NotOwner();
    error TransferFailed();
    error Unqualified();

    /*//////////////////////////////////////////////////////////////
                                 modifiers
    //////////////////////////////////////////////////////////////*/

    modifier onlyOwner() {
        if (msg.sender != ownerStore[1] && msg.sender != ODAO) revert NotOwner();
        _;
    }

    // require(msg.sender == owner(), "Only Owner");

    // function proposeStateChange() public returns (bool) {}

    /// @notice ownership change function. execute twice
    function giveOwnership(address newOwner_) external onlyOwner returns (address) {
        if (msg.sender == ODAO) ownerStore[0] = newOwner_;
        ownerStore = ownerStore[0] == newOwner_ ? [newOwner_, newOwner_] : [newOwner_, msg.sender];
        return ownerStore[1];
    }

    /// @dev @todo: @security review token wrap
    function wrapMint(uint256 amount_) public returns (bool s) {
        if (!BaseToken.transferFrom(msg.sender, ownerStore[1], amount_)) revert TransferFailed();
        s = internalToken.wrapMint(msg.sender, amount_);

        _balanceReWeigh(amount_);
        require(s);
    }

    function unwrapBurn(uint256 amount_) public returns (bool s) {
        if (!internalToken.unwrapBurn(msg.sender, amount_)) revert TransferFailed();

        s = BaseToken.transfer(msg.sender, amount_);

        _balanceReWeigh(amount_);

        require(s);
    }

    /// @dev prescriptive ? limit max inflation rate
    function setPerSecondInterestRate(uint256 ratePerSec) external onlyOwner {
        inflationRateLastUse[0] = ratePerSec;

        emit AdjustedRate();
    }

    function mintMembershipToken(address to_) external returns (bool s) {
        Membrane memory M = IoDAO(ODAO).inUseMembrane(address(this));

        uint256 i;
        s = true;
        for (i; i < M.tokens.length;) {
            s = s && (IERC20(M.tokens[i]).balanceOf(to_) >= M.balances[i]);
            unchecked { ++ i; }
        }

        if (! s) revert Unqualified();
        s = iMR.makeMember(to_, baseID) && s;

    }
    /// mintMembership(self)
    /// setRedistributiveSignal

    /*//////////////////////////////////////////////////////////////
                                 privat
    //////////////////////////////////////////////////////////////*/

    function _balanceReWeigh(uint256 amount) private {
        uint256[][2] memory uSignal = userSignal[msg.sender];
        //uint len = uSignal.length;
        uint256 i;
        for (i; i < uSignal.length;) {
            // if (msg.sig == this.wrapMint.selector ) subunitShare[uSignal[i][0]][1] = _mint(1);
            // if (msg.sig == this.unwrapBurn.selector ) subunitShare[uSignal[i][0]][1] = _mint(1);

            unchecked {
                ++i;
            }
        }
    }

    function incrementSubDAO() external returns (uint256) {
        require(msg.sender == ODAO, "root only");
        return _incrementID();
    }

    function _incrementID() private returns (uint256) {
        unchecked {
            ++localID;
        }
        localID = localID * baseID;
        emit LocalIncrement(localID);
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
}
