// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

struct U256Storage {
    uint256 value;
}

contract Proxy {
    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    //  constant
    // immutable

    // mapping (string => string) private nome2sobrenome;
    U256Storage private counter;

    constructor(address implementation) payable {
        address owner = msg.sender;
        assembly {
            sstore(_IMPLEMENTATION_SLOT, implementation)
            sstore(_ADMIN_SLOT, owner)
        }
    }

    function implementation(bytes calldata a, bytes memory b) public {
        U256Storage storage test = counter;
    }

    function _implementation() private view returns (address implementation) {
        assembly {
            implementation := sload(_IMPLEMENTATION_SLOT)
        }
    }

    function _setImplementation(address newImplementation) private {
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
    }

    function _setAdmin(address newAdmin) private {
        assembly {
            sstore(_ADMIN_SLOT, newAdmin)
        }
    }

    function _admin() private view returns (address admin) {
        assembly {
            admin := sload(_ADMIN_SLOT)
        }
    }

    function upgrade(address newImplementation) external {
        require(msg.sender == _admin(), "Proxy: only owner");
        _setImplementation(newImplementation);
    }

    fallback(bytes calldata data) external payable returns (bytes memory result) {
        bool success;
        (success, result) = _implementation().delegatecall(data);
        require(success, string(result));
    }
}
