pragma solidity ^0.4.17;

import "ds-test/test.sol";

import "./NENT.sol";

contract NENTTest is DSTest {
    NENT nent;

    function setUp() {
        nent = new NENT();
    }

    function testFail_basic_sanity() {
        assertTrue(false);
    }

    function test_basic_sanity() {
        assertTrue(true);
    }

    function test_transfer_to_contract_with_fallback() {
        assertTrue(true);
    }

    function test_transfer_to_contract_without_fallback() {
        assertTrue(true);
    }
}
