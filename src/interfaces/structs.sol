struct Membrane {
    address[] tokens;
    uint256[] balances;
    bytes meta;
}

struct ExternallCall {
    address callPointAddress;
    address eligibleCaller;
    uint256 lastCalledAt;
    bytes callData;
}
