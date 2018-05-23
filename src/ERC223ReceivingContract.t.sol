pragma solidity ^0.4.17;

import "ds-test/test.sol";

import "./NENT.sol";
import "./ERC223ReceivingContract.sol";

contract TokenReceivingEchoDemo {

    NENT nent;

    function TokenReceivingEchoDemo(address _token)
    {
        nent = NENT(_token);
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public
    {
        // check that the msg.sender _token is equal to token address
        require(msg.sender == address(nent));
        
        nent.transfer(_from, _value);
    }

    function anotherTokenFallback(address _from, uint256 _value, bytes _data) public
    {
        // check that the msg.sender _token is equal to token address
        require(msg.sender == address(nent));
        
        nent.transfer(_from, _value);
    }

    function tokenFallback(address _from, uint256 _value) public
    {
        // check that the msg.sender _token is equal to token address
        require(msg.sender == address(nent));
        
        nent.transfer(_from, _value);
    }
}

contract Nothing {
    // do not have receiveToken API
}

contract ERC223ReceivingContractTest is DSTest, TokenController {
    TokenReceivingEchoDemo echo;
    NENT nent;
    Nothing nothing;

    function proxyPayment(address _owner) payable returns(bool){
        return true;
    }

    function onTransfer(address _from, address _to, uint _amount) returns(bool){
        return true;
    }

    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool)
    {
        return true;
    }

    function setUp() {
        nent = new NENT();
        echo = new TokenReceivingEchoDemo(address(nent));
        nothing = new Nothing();
    }

    function testFail_basic_sanity() {
        nent.mint(this, 10000);

        assertEq(nent.balanceOf(this) , 10000);

        // fail
        nent.transfer(address(nothing), 100, "0x");

        assertEq(nent.balanceOf(this) , 10000);

    }

    function test_token_fall_back_with_data() {
        nent.mint(this, 10000);
        nent.transfer(address(echo), 5000, "");

        assertEq(nent.balanceOf(this) , 10000);

        // https://github.com/dapphub/dapp/issues/65
        // need manual testing
        //nent.transfer(address(echo), 5000, "0x", "anotherTokenFallback(address,uint256,bytes)");

        //assertEq(nent.balanceOf(this) , 10000);

        nent.transfer(address(nothing), 100);
    }

    function test_token_fall_back_direct() {
        nent.mint(this, 10000);

        assertTrue(nent.balanceOf(this) == 10000);

        nent.transfer(address(echo), 5000);

        assertTrue(nent.balanceOf(this) == 10000);
    }
}

