// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {VerificarAssinatura} from "../src/VerificarAssinatura.sol";

contract VerificarAssinaturaTest is Test {
    VerificarAssinatura public assinatura;

    function setUp() external {
        vm.deal(msg.sender, 1000 ether);
        assinatura = new VerificarAssinatura();
    }

    function test_signature() external {
        uint256 privateKey = vm.randomUint();
        address signer = vm.addr(privateKey);

        bytes memory mensagem = abi.encodePacked("\x19Ethereum Signed Message:\n9", "Ola mundo");
        bytes32 hash = keccak256(mensagem);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);

        mensagem = abi.encodePacked("\x19Ethereum Signed Message:\n11", "outra coisa");
        bytes32 hashFraudulento = keccak256(mensagem);
        
        // Assinatura Digital Maleavel
        // É quando você consegue gerar varias assinaturas válidas,
        // para uma mesma mensagem.
        address recovered = ecrecover(hashFraudulento, v, r, s);
        vm.assertEq(signer, recovered);
    }
}
