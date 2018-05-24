pragma solidity ^0.4.23;

import "ds-test/test.sol";

import "./ECRecovery.sol";

contract ECRecoveryTest is DSTest {

    function setUp() {
    }

    function test_v0() {
        bytes32 hash = 0x47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad;
        bytes memory sig = "\xac\xa7\xda\x99\x7a\xd1\x77\xf0\x40\x24\x0c\xdc\xcf\x69\x05\xb7\x1a\xb1\x6b\x74\x43\x43\x88\xc3\xa7\x2f\x34\xfd\x25\xd6\x43\x93\x46\xb2\xba\xc2\x74\xff\x29\xb4\x8b\x3e\xa6\xe2\xd0\x4c\x13\x36\xea\xce\xaf\xda\x3c\x53\xab\x48\x3f\xc3\xff\x12\xfa\xc3\xeb\xf2\x00";

        assertEq(ECRecovery.recover(hash, sig), 0x0e5cb767cce09a7f3ca594df118aa519be5e2b5a);
    }

    function test_v1() {
        bytes32 hash = 0x47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad;
        bytes memory sig = "\xde\xba\xaa\x0c\xdd\xb3\x21\xb2\xdc\xaa\xf8\x46\xd3\x96\x05\xde\x7b\x97\xe7\x7b\xa6\x10\x65\x87\x85\x5b\x91\x06\xcb\x10\x42\x15\x61\xa2\x2d\x94\xfa\x8b\x8a\x68\x7f\xf9\xc9\x11\xc8\x44\xd1\xc0\x16\xd1\xa6\x85\xa9\x16\x68\x58\xf9\xc7\xc1\xbc\x85\x12\x8a\xca\x01";
        
        
        assertEq(ECRecovery.recover(hash, sig), 0x8743523d96a1b2cbe0c6909653a56da18ed484af);
    }

    function test_verify_qtum_message() {
        // QeaLeQwRUYUEFQCoiTWsSrpsKzEMf8Udmr
        // TEST----This is a test.
        // IPD1NX0lzsADLRGOM4elvg9FFpaRU/upp9+XaEYpVSt5Wlwb3hDHxCZujiGgmc9ESQ5inaI6NcqCK+mg3GOZZYE=
        // 0xc522933d876596cc91911d39d5b70475070771e6 (gethexaddress QeaLeQwRUYUEFQCoiTWsSrpsKzEMf8Udmr)
        
        // print "\\x"+"\\x".join(x.encode('hex') for x in 'IPD1NX0lzsADLRGOM4elvg9FFpaRU/upp9+XaEYpVSt5Wlwb3hDHxCZujiGgmc9ESQ5inaI6NcqCK+mg3GOZZYE=')
        // bytes32 hash = sha256("Qtum Signed Message:\n","TEST----This is a test.");

        bytes32 hash = 0x3584e5e1e0d5b76b1031acb9c1e49a32048d7d46d3900c39ebcd4c7e80db4439;

        bytes memory sig = "\x49\x50\x44\x31\x4e\x58\x30\x6c\x7a\x73\x41\x44\x4c\x52\x47\x4f\x4d\x34\x65\x6c\x76\x67\x39\x46\x46\x70\x61\x52\x55\x2f\x75\x70\x70\x39\x2b\x58\x61\x45\x59\x70\x56\x53\x74\x35\x57\x6c\x77\x62\x33\x68\x44\x48\x78\x43\x5a\x75\x6a\x69\x47\x67\x6d\x63\x39\x45\x53\x51\x35\x69\x6e\x61\x49\x36\x4e\x63\x71\x43\x4b\x2b\x6d\x67\x33\x47\x4f\x5a\x5a\x59\x45\x3d";

        //bytes memory sig = "IPD1NX0lzsADLRGOM4elvg9FFpaRU/upp9+XaEYpVSt5Wlwb3hDHxCZujiGgmc9ESQ5inaI6NcqCK+mg3GOZZYE=";

        assertEq(ECRecovery.recover(hash, sig), 0xc522933d876596cc91911d39d5b70475070771e6);
    }
}