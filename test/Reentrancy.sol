// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Reentrancy} from "../src/Reentrancy.sol";

contract SimpleTest is Test {
    Reentrancy public simple;

    function setUp() external {
        vm.deal(msg.sender, 1000 ether);
        simple = new Reentrancy{value: 100 ether}();
    }

    function test_simple() external {
        (bool success, bytes memory revertMessage) = address(simple).call{gas: 100_000}("");
        assertFalse(success);
        assertEq(revertMessage, abi.encodeWithSignature("Error(string)", ("reentrada detectada!")));
    }
}
