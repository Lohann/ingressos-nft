// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {CounterV1} from "../src/CounterV1.sol";

contract CounterV1Test is Test {
    CounterV1 public counter;

    constructor() {
        counter = new CounterV1();
    }

    function test_increment() external {
        uint256 antes = gasleft();
        counter.increment(); // Incluir o custo base
        uint256 depois = gasleft();
        uint256 total = antes - depois;
        console.log("total: ", total);
    }
}
