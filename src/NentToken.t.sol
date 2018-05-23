pragma solidity ^0.4.17;

import "ds-test/test.sol";

import "./NentToken.sol";

contract NentTokenTest is DSTest {
    NentToken token;

    function setUp() public {
        token = new NentToken();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
