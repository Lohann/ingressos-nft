// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Reentrancy Attack
contract Reentrancy {
    // Reentrancy Guard
    // uint256 private guard;

    bytes32 private constant REENTRANCY_GUARD_SLOT = 0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;
    uint256 private constant NOT_ENTERED = 0;
    uint256 private constant ENTERED = 1;

    constructor() payable {}

    function setGuard(uint256 newValue) private {
        // 22k     -> simples
        // 5k      -> sem criar dados no slot
        // 200 gas -> usando o transient storage
        assembly {
            tstore(REENTRANCY_GUARD_SLOT, newValue)
        }
    }

    function guard() private view returns (uint256 val) {
        assembly {
            val := tload(REENTRANCY_GUARD_SLOT)
        }
    }

    // 21k -> custo base de um transfer
    fallback() external payable {
        require(guard() == NOT_ENTERED, "reentrada detectada!");
        setGuard(ENTERED);
        // Não utilizamos transfer, pois Por default transfer disponibilzia 2300 gas
        // carteiras multi-assinatura precisam de mais que isso.
        (bool success, bytes memory message) = payable(this).call{gas: gasleft()}("");
        assembly {
            // Se a chamada reverteu, repasse a mensagem de erro.
            if not(success) { revert(add(message, 32), mload(message)) }
        }
        setGuard(NOT_ENTERED);
    }
}
