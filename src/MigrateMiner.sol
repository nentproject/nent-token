pragma solidity ^0.4.23;

import "./NENT.sol";

contract MigrateMiner is DSAuth{
    struct Request {
        address addr;
        uint amount;
        bytes32 qtumAddress;
        string qtumSig;
        bool confirmed;
    }

    NENT public  nent;
    address public requestAuthority;
    address public confirmAuthority;

    mapping (address => Request) public mintRequests;
    mapping (bytes32 => address) public addressMapping;

    constructor(address _nent, address _requestAuthority, address _confirmAuthority) public {
        nent = NENT(_nent);

        requestAuthority = _requestAuthority;
        confirmAuthority = _confirmAuthority;
    }

    modifier isRequestAuth {
        require(msg.sender == requestAuthority);
        _;
    }

    modifier isConfirmAuth {
        require(msg.sender == confirmAuthority);
        _;
    }

    function mintRequest(bytes32 _qtumAddress, string _qtumSig, address _dest, uint256 _amount) public isRequestAuth {
        require(_amount > 0);
        require(addressMapping[_qtumAddress] == 0x0);
        require(mintRequests[_dest].amount == 0);
        // require(parseAddr(_toLower(_message)) == _dest);

        addressMapping[_qtumAddress] = _dest;
        mintRequests[_dest] = Request(_dest, _amount, _qtumAddress, _qtumSig, false);

        emit MintRequest(_qtumAddress, _qtumSig, _dest, _amount);
    }

    function confirmRequest(address _dest, uint256 _amount) public isConfirmAuth {
        require(_amount > 0);
        require(mintRequests[_dest].amount > 0);
        require(! mintRequests[_dest].confirmed);

        require(mintRequests[_dest].amount == _amount);

        mintRequests[_dest].confirmed = true;

        nent.transfer(_dest, _amount);

        emit ConfirmRequest(_dest, _amount);
    }


    /// @notice This method can be used by the owner to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) auth {
        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }

        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);

        emit ClaimedTokens(_token, owner, balance);
    }

    event MintRequest(bytes32 indexed qtumAddress, string qtumSig, address dest, uint256 amount);

    event ConfirmRequest(address indexed dest, uint256 amount);

    event ClaimedTokens(address indexed _token, address indexed _owner, uint _amount);
}