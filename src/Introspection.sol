// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// referencia: https://eips.ethereum.org/EIPS/eip-7201
library Eip7201Storage {
    // ERC-7201 Namespace do contrato Introspection
    // SLOT = keccak256("erc7201:auditoria-smart-contracts.introspection") - 1
    uint256 internal constant NAMESPACE = 0x642bd69546c74145ed0fab1bc7cb2886189217e6d49783086c81530407e61bb7;

    // @custom:storage-location erc7201:auditoria-smart-contracts.introspection
    struct Storage {
        uint128 a; // slot   0..128
        uint128 b; // slot 128..256
    }

    // Essa função é `pure`, ou seja não acessa o storage
    // apenas devolve um pointeiro para o storage.
    function get() internal pure returns (Storage storage s) {
        assembly {
            s.slot := NAMESPACE
        }
    }
}

contract Introspection {
    uint128 private _a; // slot   0..128
    uint128 private _b; // slot 128..256

    constructor() {}

    /// Escreve os valores `a` e `b`.
    function setCounter(uint128 a, uint128 b) external {
        _a = a;
        _b = b;
    }

    /// Le os valores `a` e `b` armazenados.
    function counter() external view returns (uint128, uint128) {
        return (_a, _b);
    }

    /// Escreve os valores `a` e `b` usando a EIP7201
    function setCounterEIP7201(uint128 a, uint128 b) external {
        Eip7201Storage.Storage storage state = Eip7201Storage.get();
        state.a = a;
        state.b = b;
    }

    /// Le os valores `a` e `b` usando a EIP7201
    function counterEIP7201() external view returns (uint128, uint128) {
        Eip7201Storage.Storage storage state = Eip7201Storage.get();
        return (state.a, state.b);
    }

    /// Lê um valor bruto do storage, use essa função para verificar
    /// como os dados armazenados são representados na EVM.
    function sload(uint256 slot) external view returns (bytes32 value) {
        assembly {
            value := sload(slot)
        }
    }

    /// Sobrescreve um valor bruto do storage, use essa função para verificar
    /// o que acontence quando se altera dados do storage manualmente.
    function sstore(uint256 slot, bytes32 value) external {
        assembly {
            sstore(slot, value)
        }
    }
}
