pragma solidity ^0.4.13;

import "./NENT.sol";

contract MigrateMiner is DSAuth{
    struct Request {
        address addr;
        uint amount;
        bytes32 qtumAddress;
        string message;
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

    function _toLower(string str) internal returns (string) {
		bytes memory bStr = bytes(str);
		bytes memory bLower = new bytes(bStr.length);
		for (uint i = 0; i < bStr.length; i++) {
			// Uppercase character...
			if ((bStr[i] >= 65) && (bStr[i] <= 90)) {
				// So we add 32 to make it lowercase
				bLower[i] = bytes1(int(bStr[i]) + 32);
			} else {
				bLower[i] = bStr[i];
			}
		}
		return string(bLower);
	}

    function parseAddr(string _a) internal returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }

    function mintRequest(bytes32 _qtumAddress, string _message, string _qtumSig, address _dest, uint256 _amount) public isRequestAuth {
        require(_amount > 0);
        require(addressMapping[_qtumAddress] == 0x0);
        require(mintRequests[_dest].amount == 0);
        require(parseAddr(_toLower(_message)) == _dest);

        addressMapping[_qtumAddress] = _dest;
        mintRequests[_dest] = Request(_dest, _amount, _qtumAddress, _message, _qtumSig, false);

        emit MintRequest(_qtumAddress, _message, _qtumSig, _dest, _amount);
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

    event MintRequest(bytes32 indexed qtumAddress, string message, string qtumSig, address dest, uint256 amount);

    event ConfirmRequest(address indexed dest, uint256 amount);
}