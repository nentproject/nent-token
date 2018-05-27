pragma solidity ^0.4.13;

import "./NENT.sol";
import "./ECRecovery.sol";

/// general helpers.
/// `internal` so they get compiled into contracts using them.
library Helpers {
    /// returns whether `array` contains `value`.
    function addressArrayContains(address[] array, address value) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return true;
            }
        }
        return false;
    }

        // returns the digits of `inputValue` as a string.
    // example: `uintToString(12345678)` returns `"12345678"`
    function uintToString(uint256 inputValue) internal pure returns (string) {
        // figure out the length of the resulting string
        uint256 length = 0;
        uint256 currentValue = inputValue;
        do {
            length++;
            currentValue /= 10;
        } while (currentValue != 0);
        // allocate enough memory
        bytes memory result = new bytes(length);
        // construct the string backwards
        uint256 i = length - 1;
        currentValue = inputValue;
        do {
            result[i--] = byte(48 + currentValue % 10);
            currentValue /= 10;
        } while (currentValue != 0);
        return string(result);
    }

    /// returns whether signatures (whose components are in `vs`, `rs`, `ss`)
    /// contain `requiredSignatures` distinct correct signatures
    /// where signer is in `allowed_signers`
    /// that signed `message`
    function hasEnoughValidSignatures(bytes32 message, uint8[] vs, bytes32[] rs, bytes32[] ss, address[] allowed_signers, uint256 requiredSignatures) internal pure returns (bool) {
        // not enough signatures
        if (vs.length < requiredSignatures) {
            return false;
        }

        var messageHash = MessageSigning.hashMessage(message);

        var encountered_addresses = new address[](allowed_signers.length);

        for (uint256 i = 0; i < requiredSignatures; i++) {
            var recovered_address = ecrecover(messageHash, vs[i], rs[i], ss[i]);
            // only signatures by addresses in `addresses` are allowed
            if (!addressArrayContains(allowed_signers, recovered_address)) {
                return false;
            }
            // duplicate signatures are not allowed
            if (addressArrayContains(encountered_addresses, recovered_address)) {
                return false;
            }
            encountered_addresses[i] = recovered_address;
        }
        return true;
    }
}

/// Library used only to test Helpers library via rpc calls
library HelpersTest {
    function addressArrayContains(address[] array, address value) public pure returns (bool) {
        return Helpers.addressArrayContains(array, value);
    }

    function uintToString(uint256 inputValue) public pure returns (string str) {
        return Helpers.uintToString(inputValue);
    }

    function hasEnoughValidSignatures(bytes32 message, uint8[] vs, bytes32[] rs, bytes32[] ss, address[] addresses, uint256 requiredSignatures) public pure returns (bool) {
        return Helpers.hasEnoughValidSignatures(message, vs, rs, ss, addresses, requiredSignatures);
    }
}

// helpers for message signing.
// `internal` so they get compiled into contracts using them.
library MessageSigning {
    function recoverAddressFromSignedMessage(bytes signature, bytes32 message) internal pure returns (address) {
        require(signature.length == 65);
        bytes32 r;
        bytes32 s;
        bytes1 v;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := mload(add(signature, 0x60))
        }
        return ecrecover(hashMessage(message), uint8(v), r, s);
    }

    function hashMessage(bytes32 message) internal pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        return keccak256(prefix, Helpers.uintToString(message.length), message);
    }
}


/// Library used only to test MessageSigning library via rpc calls
library MessageSigningTest {
    function recoverAddressFromSignedMessage(bytes signature, bytes32 message) public pure returns (address) {
        return MessageSigning.recoverAddressFromSignedMessage(signature, message);
    }
}

contract MigrateMiner is DSAuth{
    NENT public  nent;
    uint256 public requiredSignatures;
    address[] public mintAuthorities;

    constructor(address _nent, uint256 requiredSignaturesParam, address[] authoritiesParam) public {
        nent = NENT(_nent);

        require(requiredSignaturesParam != 0);
        require(requiredSignaturesParam <= authoritiesParam.length);

        requiredSignatures = requiredSignaturesParam;
        mintAuthorities = authoritiesParam;
    }

    /// `vs`, `rs`, `ss` are the components of the signatures.
    function multiSigMint(address _dest, uint256 _amount, uint8[] vs, bytes32[] rs, bytes32[] ss) auth {
        // TODO: this is the formating method.
        bytes32 message = keccak256(_dest, _amount);

        require(Helpers.hasEnoughValidSignatures(message, vs, rs, ss, mintAuthorities, requiredSignatures));

        nent.mint(_dest, _amount);
    }
}