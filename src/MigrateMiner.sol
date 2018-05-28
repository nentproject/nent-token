pragma solidity ^0.4.13;

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

        nent.mint(_dest, _amount);

        emit ConfirmRequest(_dest, _amount);
    }

    event MintRequest(bytes32 indexed qtumAddress, string qtumSig, address dest, uint256 amount);

    event ConfirmRequest(address indexed dest, uint256 amount);
}