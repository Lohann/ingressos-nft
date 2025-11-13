// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {CounterV1} from "../src/CounterV1.sol";

contract CounterV1Test is Test {
    CounterV1 private _counter;

    /**
     * Contrato auxiliar que não consome gas, possui apenas o opcode STOP.
     * Como não consome gas, esse contrato é utilizado para calcular o "overhead"
     * de gas ao executar uma função.
     */
    address private constant EMPTY_CONTRACT = address(uint160(uint256(keccak256("empty contract"))));

    constructor() {
        // Associa um código ao endereço `EMPTY_CONTRACT`
        vm.etch(EMPTY_CONTRACT, hex"00");
    }

    function setUp() external {
        _counter = new CounterV1();
    }

    /// Forma incorreta de se medir o quanto de gas
    /// uma determinada função consome.
    function test_incrementv1() external {
        uint256 antes = gasleft();
        _counter.increment();
        uint256 depois = gasleft();
        uint256 total = antes - depois;
        console.log("total: ", total);
    }

    /// Hack para computar o custo de execução de uma função.
    function test_incrementv2() external {
        assertEq(_counter.counter(), 1);

        // calldata para a função `increment`
        bytes memory data = abi.encodeCall(CounterV1.increment, ());
        {
            uint256 custoExecucao;
            (custoExecucao,) = estimateGas(
                address(_counter), // endereço do CounterV1
                50_000, // gas limit
                0, // valor
                data // calldata para a função `increment`
            );
            console.log("custo execucao: ", custoExecucao);
        }
        assertEq(_counter.counter(), 2);
    }

    /// Calcula o custo de execução de uma determinada função, descontando o overhead.
    function estimateGas(address addr, uint256 gasLimit, uint256 value, bytes memory data)
        public
        returns (uint256 executionCost, bytes memory result)
    {
        require(addr.code.length > 0, "addr is not a contract");
        require(msg.sender.balance >= value, "insufficient funds");

        // Calcula a quantidade minima de gas que precisa estar disponível.
        uint256 gasRequired = gasLimit + 21_000 + data.length * 16;

        if (addr != EMPTY_CONTRACT) {
            // Calcula o overhead
            (executionCost,) = this.estimateGas{gas: gasleft()}(EMPTY_CONTRACT, 21_000 + data.length * 16, 0, data);
        } else {
            // Se `addr == EMPTY_CONTRACT`, então o valor
            // retornado será o overhead de gas.
            executionCost = 0;
        }

        // Verifica se ainda tem gas suficiente
        require(gasRequired < gasleft(), "insufficient gas left");

        assembly {
            result := mload(0x40)
            let len := mload(data)
            let ptr := add(data, 0x20)

            // Desconta o overhead
            executionCost := sub(gas(), executionCost)

            // Chama o contrato, calculando o custo de execução.
            let success :=
                call(
                    gasLimit, // limite de gas
                    addr, // endereço do contrato
                    value, // valor a ser transferido
                    ptr, // ponteiro para o calldata na memória
                    len, // tamanho do calldata em bytes
                    0, // pointeiro para o resultado (opcional)
                    0 // tamanho do resultado (opcional)
                )
            executionCost := sub(executionCost, gas())

            // Armazena o tamanho do resultado
            mstore(result, returndatasize())

            // Copia os bytes do resultado
            ptr := add(result, 0x20)
            returndatacopy(ptr, 0, returndatasize())

            // Aloca os bytes necessários para armenar o resultado.
            mstore(0x40, shl(5, shr(5, add(add(ptr, returndatasize()), 31))))

            // Se a call falhou, reverte
            if iszero(success) { revert(ptr, returndatasize()) }
        }
    }

    function _call(address addr, uint256 gasLimit, uint256 value, bytes memory data)
        private
        returns (bool success, bytes memory result)
    {
        (success, result) = payable(addr).call{gas: gasLimit, value: value}(data);
    }
}
