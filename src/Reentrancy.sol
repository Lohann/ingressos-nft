// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Reentrancy Attack
contract Reentrancy {
    // Reentrancy Guard
    bool private guard;

    uint256 private counter;

    constructor() payable {}

    fallback() external payable {
        require(guard == false, "reentracy");
        guard = true;
        // Carteira multi-assinatura
        // Por default transfer disponibilzia 2300 gas
        payable(this).call{gas: gasleft()}("");
        guard = false;
    }
}
