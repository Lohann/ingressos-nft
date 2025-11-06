// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {CounterV1} from "./CounterV1.sol";

contract CounterV2 is CounterV1 {
    constructor() {}

    function decrement() public {
        _counter -= 1;
    }
}
