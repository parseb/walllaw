// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/tokens/ERC721.sol";

contract M721222 is ERC721("LinkeGaard Community Meeting POAP", "POAP") {
    address deployer = address(4896);
    address Agent1 = address(16);
    address Agent2 = address(32);
    address Agent3 = address(48);
    address add1 = 0xb3F204a5F3dabef6bE51015fD57E307080Db6498;
    address add2 = 0x65Cf1e0f55BD97696ce430aAcC97b5E7831E0fC2;
    address add3 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address anvil_1 = 0x01aFf83D7e116CFf1567DF3916Fae80AbE4AE643;
    address anvil_2 = 0x323525cB37428d72e33B8a3d9a72F848d08Bf2B7;
    address anvil_3 = 0x5df6cF21815ca55057bb5cA159A3130c193bb0a1;
    address anvil_4 = 0xEdc4E5c7FfAD492dE7c0c5889986aD3e8B578627;
    address anvil_5 = 0x9424C74e27398a0EB9e994FFeBf6239fa4515cd2;
    address LINKE1 = 0xb5E9851AAf406B8f4383A3073efd3086f76d420C;

    uint256 id;

    constructor() {
        _mint(address(0xb3F204a5F3dabef6bE51015fD57E307080Db6498), 10_000_000 ether);
        _mint(msg.sender, 1);
        _mint(deployer, 2);
        _mint(Agent1, 3);
        _mint(add1, 4);
        _mint(add2, 5);
        _mint(add3, 6);
        _mint(Agent2, 7);
        _mint(Agent3, 8);
        _mint(anvil_1, 9);
        _mint(anvil_2, 10);
        _mint(anvil_3, 11);
        _mint(anvil_4, 20);
        _mint(anvil_5, 30);

        _mint(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266), 306);
        _mint(address(0x90b29ee9ee4619b8250d2A1EF75d891Aea02cB4F), 9999);
        _mint(address(0xFbE328d863F0C7378dD58dFFaE5A9fEBab836df8), 99999);

        _mint(LINKE1, 23);

        id = 100;
    }

    function mintTo(address to_) external {
        require(msg.sender == 0xE7b30A037F5598E4e73702ca66A59Af5CC650Dcd);
        unchecked {
            ++id;
        }
        _mint(to_, id);
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return
        "https://images.unsplash.com/photo-1628243989859-db92e2de1340?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8Y29tbXVuaXR5JTIwZ2FyZGVufGVufDB8fDB8fA";
    }
}
