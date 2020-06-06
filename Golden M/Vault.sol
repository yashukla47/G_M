pragma solidity ^0.5.1;
 
 import "./math/SafeMath.sol";
 import "./Proxy.sol";
 import "./ERC223.sol";
 
 contract Vault {
     
    using SafeMath for uint;
    Proxy proxy;
    ERC223 erc223;
    
    event LogTransferToken(address _To, uint _Amount, address _by);
    event Logwithdraw(uint _Amount, address _ValutAddress,address _by);

    constructor(address _ProxyAddress) public
    {
       proxy = Proxy(_ProxyAddress); 
    }
    
    modifier addressValid(address _address) {
        require(_address != address(0), "Utils:: INVALID_ADDRESS");
        _;
    }
    
    
    function transferTokens 
    (
        address _To, 
        address _TokenAddress, 
        uint _Amount 
    )
    public
    addressValid(_TokenAddress)
    addressValid(_To)
    {
        require(proxy.isAccountant(msg.sender), "Vault:: transferToken ACCOUNTANT_NOT_AUTHORIZED");
        require(proxy.AccountantVaultAddress(msg.sender) == address(this), "Vault:: transferToken ACCOUNTANT_NOT_AUTHORIZED_FOR_THIS_VAULT");
        require(proxy.isTokenAddress(_TokenAddress), "Vault:: transferToken NOT_A_TOKEN_ADDRESS");
        require(proxy.transferBalance(_To)>= _Amount, "Vault:: transferToken  NO_SUFFICIENT_TRANSFER_BALANCE" );
        erc223 = ERC223(_TokenAddress);
        erc223.transfer(_To, _Amount);
        proxy.updateTransferBalance(_To, _Amount);

        emit LogTransferToken(_To, _Amount, msg.sender);
    }
    
    function withdraw
    (
        uint _Amount,
        address _TokenAddress
    ) 
    public
    
    {
        require(proxy.isAdmin(msg.sender), "Vault:: withdraw ADMIN_NOT_AUTHORIZED");
        if (_TokenAddress == address(0x0) )
        {
            msg.sender.transfer(_Amount);
        }
        if (_TokenAddress != address(0x0))
        {
        erc223 = ERC223(_TokenAddress);
        erc223.transfer(msg.sender, _Amount);
        }
        
        emit Logwithdraw(_Amount, address(this), msg.sender);

    }
    
 }    
    
