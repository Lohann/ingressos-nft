// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Reentrancy Attack
contract Reentrancy {
    // Reentrancy Guard
    bool private guard;

    constructor() payable {}

    fallback() external payable {
        require(guard == false, "reentrada detectada!");
        guard = true;
        // Não utilizamos transfer, pois Por default transfer disponibilzia 2300 gas
        // carteiras multi-assinatura precisam de mais que isso.
        (bool success, bytes memory message) = payable(this).call{gas: gasleft()}("");
        assembly {
            // Se a chamada reverteu, repasse a mensagem de erro.
            if not(success) { revert(add(message, 32), mload(message)) }
        }
        guard = false;
    }
}
