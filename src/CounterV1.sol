// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract CounterV1 {
    uint256 internal _counter; // slot 0

    constructor() {
        _counter = 1;
    }

    function counter() public view returns (uint256) {
        return _counter;
    }

    function increment() public {
        _counter += 1;
    }
}
