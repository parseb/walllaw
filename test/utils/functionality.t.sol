pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../../src/interfaces/IMember1155.sol";
import "../../src/interfaces/iInstanceDAO.sol";
import "../../src/interfaces/IDAO20.sol";

import "../../src/oDAO.sol";
import "../../src/Member1155.sol";
import "../mocks/mockERC20.sol";

contract MyUtils is Test {
    ODAO O;
    IERC20 BaseE20;
    IMemberRegistry iMR;

    address deployer = address(4896);
    address Agent1 = address(16);
    address Agent2 = address(32);
    address Agent3 = address(48);

    constructor() {
        vm.prank(deployer, deployer);
        O = new ODAO();
        BaseE20 = IERC20(address(new M20()));
        iMR = IMemberRegistry(O.getMemberRegistryAddr());
    }

    function _createAnERC20() public returns (address) {
        return address(new M20());
    }

    function _createDAO(address _baseToken) public returns (address DAO) {
        return address(O.createDAO(address(_baseToken)));
    }
    /// @dev if you use this in a loop, skip(1) second between iterations

    function _createBasicMembrane() public returns (uint256 basicMid) {
        address[] memory tokens_ = new address[](1);
        uint256[] memory balances_ = new uint[](1);

        tokens_[0] = address(BaseE20);
        balances_[0] = uint256(1000);
        basicMid = O.createMembrane(tokens_, balances_, bytes(abi.encodePacked(keccak256(abi.encode(block.timestamp)))));
    }

    function _setInflation(uint256 percent_, address _DAOaddr) public {
        vm.prank(Agent1);
        iInstanceDAO(_DAOaddr).signalInflation(percent_);
    }

    function _createSubDaos(uint256 howMany_, address parentDAO_) public returns (address[] memory subDs) {
        uint256 basicMembrane = _createBasicMembrane();
        uint256 i;
        for (i; i < howMany_;) {
            O.createSubDAO(basicMembrane, parentDAO_);
            unchecked {
                ++i;
            }
        }

        subDs = O.getDAOsOfToken(iInstanceDAO(parentDAO_).internalTokenAddress());
    }

    function _createNestedDAOs(address startDAO_, uint256 membrane, uint256 levels_)
        public
        returns (address[] memory nestedBaseIs0)
    {
        uint256 i;
        nestedBaseIs0 = new address[](levels_);
        nestedBaseIs0[i] = startDAO_;
        assertTrue(iInstanceDAO(nestedBaseIs0[i]).isMember(Agent1), "not member");
        membrane = membrane == 0 ? _createBasicMembrane() : membrane;

        i = 1;
        for (i; i < levels_;) {
            nestedBaseIs0[i] = O.createSubDAO(membrane, nestedBaseIs0[i - 1]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice creates and assigns basic membrane (A1) to given DAOaddr
    function _setCreateMembrane(address DAO_) public {
        iInstanceDAO DAO = iInstanceDAO(DAO_);

        /// active membrane of dInstance
        uint256 currentMembrane;

        currentMembrane = O.inUseMembraneId(DAO_);
        assertTrue(currentMembrane == 0, "has unexpected default membrane");

        address[] memory a = new address[](1);
        uint256[] memory u = new uint[](1);

        a[0] = DAO.baseTokenAddress();
        u[0] = 101_000;
        uint256 membrane1 = O.createMembrane(a, u, bytes("url://deployer_hasaccessmeta"));

        vm.prank(DAO_);
        O.setMembrane(DAO_, membrane1);

        assertTrue((O.inUseMembraneId(DAO_) == membrane1), "failed to set");
    }

    function _setNewInflation(address DAO_, uint256 inflation_) public {
        iInstanceDAO DAO = iInstanceDAO(DAO_);
        uint256 initInflation = DAO.baseInflationRate();
        _setInflation(inflation_, address(DAO));
        uint256 initPerSec = DAO.baseInflationPerSec();

        if (initInflation == inflation_) _setInflation(inflation_, DAO_);
        assertFalse(initInflation == DAO.baseInflationRate(), "failed to update infaltion");
        assertTrue(initPerSec != 0, "per sec not updated");
    }

    function testImportCheck() public {
        assertTrue(address(O) != address(0));
        assertTrue(address(BaseE20) != address(0));
        assertTrue(address(iMR) != address(0));
    }
}
