# IoDAO
[Git Source](https://github.com/parseb/odao.lol/blob/6589851af8e0b7d49abf07f2bf59c55824bb2d57/src/interfaces/IoDAO.sol)


## Functions
### isDAO


```solidity
function isDAO(address toCheck) external view returns (bool);
```

### createDAO


```solidity
function createDAO(address BaseTokenAddress_) external returns (address newDAO);
```

### createSubDAO


```solidity
function createSubDAO(uint256 membraneID_, address parentDAO_) external returns (address subDAOaddr);
```

### getParentDAO


```solidity
function getParentDAO(address child_) external view returns (address);
```

### getDAOsOfToken


```solidity
function getDAOsOfToken(address parentToken) external view returns (address[] memory);
```

### getDAOfromID


```solidity
function getDAOfromID(uint256 id_) external view returns (address);
```

### getTrickleDownPath


```solidity
function getTrickleDownPath(address floor_) external view returns (address[] memory);
```

