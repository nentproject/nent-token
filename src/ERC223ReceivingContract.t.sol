pragma solidity ^0.4.17;

import "ds-test/test.sol";

import "./OMT.sol";
import "./ERC223ReceivingContract.sol";

contract TokenReceivingEchoDemo {

    OMT omt;

    function TokenReceivingEchoDemo(address _token)
    {
        omt = OMT(_token);
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public
    {
        // check that the msg.sender _token is equal to token address
        require(msg.sender == address(omt));
        
        omt.transfer(_from, _value);
    }

    function anotherTokenFallback(address _from, uint256 _value, bytes _data) public
    {
        // check that the msg.sender _token is equal to token address
        require(msg.sender == address(omt));
        
        omt.transfer(_from, _value);
    }

    function tokenFallback(address _from, uint256 _value) public
    {
        // check that the msg.sender _token is equal to token address
        require(msg.sender == address(omt));
        
        omt.transfer(_from, _value);
    }
}

contract Nothing {
    // do not have receiveToken API
}

contract ERC223ReceivingContractTest is DSTest, TokenController {
    TokenReceivingEchoDemo echo;
    OMT omt;
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
        omt = new OMT();
        echo = new TokenReceivingEchoDemo(address(omt));
        nothing = new Nothing();
    }

    function testFail_basic_sanity() {
        omt.mint(this, 10000);

        assertEq(omt.balanceOf(this) , 10000);

        // fail
        omt.transfer(address(nothing), 100, "0x");

        assertEq(omt.balanceOf(this) , 10000);

    }

    function test_token_fall_back_with_data() {
        omt.mint(this, 10000);
        omt.transfer(address(echo), 5000, "");

        assertEq(omt.balanceOf(this) , 10000);

        // https://github.com/dapphub/dapp/issues/65
        // need manual testing
        omt.transfer(address(echo), 5000, "0x", "anotherTokenFallback(address,uint256,bytes)");

        assertEq(omt.balanceOf(this) , 10000);

        omt.transfer(address(nothing), 100);
    }

    function test_token_fall_back_direct() {
        omt.mint(this, 10000);

        assertTrue(omt.balanceOf(this) == 10000);

        omt.transfer(address(echo), 5000);

        assertTrue(omt.balanceOf(this) == 10000);
    }
}

