// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Introspection, Eip7201Storage} from "../src/Introspection.sol";

contract SimpleTest is Test {
    Introspection public introspection;

    function setUp() external {
        vm.deal(msg.sender, 1000 ether);
        introspection = new Introspection();
    }

    function test_introspection() external {
        introspection.setCounter(0xdeadbeef, 0xbabebeef);
        (uint128 a, uint128 b) = introspection.counter();
        assertEq(a, 0xdeadbeef);
        assertEq(b, 0xbabebeef);

        // Obs: utilize esse comando apra ver o resultado do console.log:
        // forge test --match-test=test_introspection -vv
        console.logBytes32(introspection.sload(0));
    }

    function test_introspectionEIP7201() external {
        introspection.setCounterEIP7201(0xdeadbeef, 0xbabebeef);
        (uint128 a, uint128 b) = introspection.counterEIP7201();
        assertEq(a, 0xdeadbeef);
        assertEq(b, 0xbabebeef);

        // Obs: utilize esse comando apra ver o resultado do console.log:
        // forge test --match-test=test_introspection -vv
        uint256 namespace = Eip7201Storage.NAMESPACE;
        console.logBytes32(introspection.sload(namespace));
    }
}
