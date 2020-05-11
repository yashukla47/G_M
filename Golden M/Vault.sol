pragma solidity ^0.5.1;
 
 import "./math/SafeMath.sol";
 import "./Proxy.sol";
 import "./ERC223.sol";
 
 contract Vault {
     
    using SafeMath for uint;
    Proxy proxy;
    ERC223 erc223;
    
    mapping (address => bool) isAccountant;
    
    
    address[] public AccountantsArray;
    event LogAccountantAdded(address indexed _Accountant, address _by);
    event LogAccountantRemoved(address indexed _Accountant, address _by);
    event LogTransferToken(address _To, uint _Amount, address _by);


    constructor(address _ProxyAddress) public
    {
       proxy = Proxy(_ProxyAddress); 
    }
    
    modifier addressValid(address _address) {
        require(_address != address(0), "Utils:: INVALID_ADDRESS");
        _;
    }
    
    function getAllAccountant()
        public
        view
        returns(address[] memory)
    {
        return AccountantsArray;
    }

    function addAccountant
        (
            address _Accountant
        )
            external
            addressValid(_Accountant)
        {   
            require(proxy.isAdmin(msg.sender), "vault:: addAccountant NOT_ADMIN");
            require(!isAccountant[_Accountant], "vault:: addAccountant ACCOUNT_ALREADY_EXISTS");
    
            AccountantsArray.push(_Accountant);
            isAccountant[_Accountant] = true;
    
            emit LogAccountantAdded(_Accountant, msg.sender);
        }
    
    function removeAccountant
    (
        address _Accountant
    ) 
        external
        addressValid(_Accountant)
    {   
        require(proxy.isAdmin(msg.sender), "vault:: addAccountant NOT_ADMIN");
        require(isAccountant[_Accountant], "Config::removeAdmin ADMIN_DOES_NOT_EXIST");
        require(msg.sender != _Accountant, "Config::removeAdmin ADMIN_NOT_AUTHORIZED");

        isAccountant[_Accountant] = false;

        for (uint i = 0; i < AccountantsArray.length - 1; i++) {
            if (AccountantsArray[i] == _Accountant) {
                AccountantsArray[i] = AccountantsArray[AccountantsArray.length - 1];
                AccountantsArray.length -= 1;
                break;
            }
        }  

        emit LogAccountantRemoved(_Accountant, msg.sender);
    }
    
    function transferTokens 
    (
        address _To, 
        address _TokenAddress, 
        uint _Amount 
    )
    external 
    addressValid(_TokenAddress)
    addressValid(_To)
    {
        require(isAccountant[msg.sender], "Vault:: transferToken ACCOUNTANT_NOT_AUTHORIZED");
        require(proxy.isTokenAddress(_TokenAddress), "Vault:: transferToken Not_A_Token_Address");
        require(proxy.transferBalance(_To)>= _Amount, "Vault:: transferToken  NO_Sufficient_Transfer_Balance" );
        erc223 = ERC223(_TokenAddress);
        erc223.transfer(_To, _Amount);
        proxy.updateTransferBalance(_To, _Amount);

        emit LogTransferToken(_To, _Amount, msg.sender);
    }
    
    
 }pragma solidity ^0.5.1;
 
 import "./math/SafeMath.sol";
 import "./Proxy.sol";
 import "./ERC223.sol";
 
 contract Vault {
     
    using SafeMath for uint;
    Proxy proxy;
    ERC223 erc223;
    
    mapping (address => bool) isAccountant;
    
    
    address[] public AccountantsArray;
    event LogAccountantAdded(address indexed _Accountant, address _by);
    event LogAccountantRemoved(address indexed _Accountant, address _by);
    event LogTransferToken(address _To, uint _Amount, address _by);


    constructor(address _ProxyAddress) public
    {
       proxy = Proxy(_ProxyAddress); 
    }
    
    modifier addressValid(address _address) {
        require(_address != address(0), "Utils:: INVALID_ADDRESS");
        _;
    }
    
    function getAllAccountant()
        public
        view
        returns(address[] memory)
    {
        return AccountantsArray;
    }

    function addAccountant
        (
            address _Accountant
        )
            external
            addressValid(_Accountant)
        {   
            require(proxy.isAdmin(msg.sender), "vault:: addAccountant NOT_ADMIN");
            require(!isAccountant[_Accountant], "vault:: addAccountant ACCOUNT_ALREADY_EXISTS");
    
            AccountantsArray.push(_Accountant);
            isAccountant[_Accountant] = true;
    
            emit LogAccountantAdded(_Accountant, msg.sender);
        }
    
    function removeAccountant
    (
        address _Accountant
    ) 
        external
        addressValid(_Accountant)
    {   
        require(proxy.isAdmin(msg.sender), "vault:: addAccountant NOT_ADMIN");
        require(isAccountant[_Accountant], "Config::removeAdmin ADMIN_DOES_NOT_EXIST");
        require(msg.sender != _Accountant, "Config::removeAdmin ADMIN_NOT_AUTHORIZED");

        isAccountant[_Accountant] = false;

        for (uint i = 0; i < AccountantsArray.length - 1; i++) {
            if (AccountantsArray[i] == _Accountant) {
                AccountantsArray[i] = AccountantsArray[AccountantsArray.length - 1];
                AccountantsArray.length -= 1;
                break;
            }
        }  

        emit LogAccountantRemoved(_Accountant, msg.sender);
    }
    
    function transferTokens 
    (
        address _To, 
        address _TokenAddress, 
        uint _Amount 
    )
    external 
    addressValid(_TokenAddress)
    addressValid(_To)
    {
        require(isAccountant[msg.sender], "Vault:: transferToken ACCOUNTANT_NOT_AUTHORIZED");
        require(proxy.isTokenAddress(_TokenAddress), "Vault:: transferToken Not_A_Token_Address");
        require(proxy.transferBalance(_To)>= _Amount, "Vault:: transferToken  NO_Sufficient_Transfer_Balance" );
        erc223 = ERC223(_TokenAddress);
        erc223.transfer(_To, _Amount);
        proxy.updateTransferBalance(_To, _Amount);

        emit LogTransferToken(_To, _Amount, msg.sender);
    }
    
    
 }