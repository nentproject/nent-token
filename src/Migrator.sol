pragma solidity ^0.4.23;

import "./NENT.sol";

contract Migrator is DSAuth{
    struct Request {
        address addr;
        uint amount;
        bytes32 qtumAddress;
        string qtumSig;
        address worker;
        bool confirmed;
    }

    NENT public  nent;
    address public requestWorker;
    address public confirmWorker;

    mapping (address => Request) public mintRequests;
    mapping (bytes32 => address) public addressMapping;

    constructor(address _nent, address _requestWorker, address _confirmWorker) public {
        nent = NENT(_nent);

        requestWorker = _requestWorker;
        confirmWorker = _confirmWorker;
    }

    modifier isRequestWorker {
        require(msg.sender == requestWorker);
        _;
    }

    modifier isConfirmWorker {
        require(msg.sender == confirmWorker);
        _;
    }

    modifier isWorker {
        require(msg.sender == confirmWorker || msg.sender == requestWorker);
        _;
    }

    function submitProof(bytes32 _qtumAddress, string _qtumSig, address _dest, uint256 _amount) public isWorker {
        require(_amount > 0);

        if (addressMapping[_qtumAddress] == 0x0)
        {
            require(mintRequests[_dest].amount == 0);

            addressMapping[_qtumAddress] = _dest;
            mintRequests[_dest] = Request(_dest, _amount, _qtumAddress, _qtumSig, msg.sender, false);

            emit MintRequest(_qtumAddress, _qtumSig, _dest, _amount, msg.sender);
        } else {
            require(_amount > 0);
            require(mintRequests[_dest].amount > 0);
            require(! mintRequests[_dest].confirmed);

            require(mintRequests[_dest].amount == _amount);

            require(addressMapping[_qtumAddress] == _dest);

            // they should not be the same worker.
            require(mintRequests[_dest].worker != msg.sender);

            require(mintRequests[_dest].qtumAddress == _qtumAddress);

            // In solidity, cannot compare two string directly, so we compare their hash instead.
            require(keccak256(mintRequests[_dest].qtumSig) == keccak256(_qtumSig));

            mintRequests[_dest].confirmed = true;

            nent.transfer(_dest, _amount);

            emit ConfirmRequest(_qtumAddress, _qtumSig, _dest, _amount, msg.sender);
        }
    }

    // 量子链地址去除首字母Q之后为33个字符，无法转换为byte32，因此还需要去掉一个首字母
    // 例如 "QT3Mae6FMDb3eRHrbEZPAv9JL55vrg3a9s" -->  byte32("2Mae6FMDb3eRHrbEZPAv9JL55vrg3a9s")
    function getProofByQtumAddress(bytes32 _qtumAddress) public view returns (address _ethAddress, uint256 _amount, address _currentWorker, string _qtumSig, bool _confirmed)
    {
        address ethAddress = addressMapping[_qtumAddress];
        Request memory r = mintRequests[ethAddress];

        return (ethAddress, r.amount, r.worker, r.qtumSig, r.confirmed);
    }

    // The _qtumAddress in return value is bytes32 of substring(2:) of original Qtum address string
    function getProofByEthereumAddress(address _ethAddress) public view returns (bytes32 _qtumAddress, uint256 _amount, address _currentWorker, string _qtumSig, bool _confirmed)
    {
        Request memory r = mintRequests[_ethAddress];

        return (r.qtumAddress, r.amount, r.worker, r.qtumSig, r.confirmed);
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

    event MintRequest(bytes32 indexed qtumAddress, string qtumSig, address dest, uint256 amount, address worker);

    event ConfirmRequest(bytes32 indexed qtumAddress, string qtumSig, address dest, uint256 amount, address worker);

    event ClaimedTokens(address indexed _token, address indexed _owner, uint _amount);
}