 pragma solidity ^0.5.1;
 
 import "./math/SafeMath.sol";
 import "./Vault.sol";
 
 contract Proxy {
     
    using SafeMath for uint;
    Vault public vault;
    
    address VaultAddress;
    mapping (address => bool) public isAdmin;
    mapping (address => bool) public isAccountant;
    mapping (address => bool) public isKyc;
    mapping (address => bool) public isTokenAddress;
    mapping (address => bool) public isVaultAddress;
    mapping (address => address) public AccountantVaultAddress;
    mapping (address => uint) public referrerLimit;
    mapping (address => uint) public transferBalance;
    mapping (address => mapping(uint => uint)) public cycleLimit;
    mapping (uint => uint) public cycleStartTime;
    mapping (uint => address) public tokenAddress;
    mapping (address => uint) public cycleNumber;
    mapping (uint => uint) public lockingEndTime; 
    

    
    address[] public AdminsArray;
    event LogAdminAdded(address indexed _Admin, address _by);
    event LogAdminRemoved(address indexed _Admin, address _by);
    
    address[] public KycArray;
    event LogKycAdded(address indexed _Kyc, address _by);
    event LogKycRemoved(address indexed _Kyc, address _by);
    
    address[] public TokenAddressArray;
    event LogTokenAddressAdded(uint _CycleNumber, address _TokenAddress, address _by);
    event LogTokenAddressRemoved(uint indexed _CycleNumber, address _TokenAddress, address _by);
    
    address[] public VaultAddressArray;
    event LogVaultAddressAdded( address _VaultAddress, address _by);
    event LogVaultAddressRemoved( address _VaultAddress, address _by);
    
    address[] public AccountantsArray;
    event LogAccountantAdded(address indexed _Accountant, address _by);
    event LogAccountantRemoved(address indexed _Accountant, address _by);
    
    event LogAccountantVaultAddressUpdated(address _ValultAddress,address indexed _AccountantAddress, address _by);
    
    event LogLockingEndTimeupdated(uint indexed _CycleNumber, uint _LockingEndTime, address _by);
    
    event LogCycleStartTimeupdated(uint indexed _CycleNumber, uint _CycleStartTime, address _by);
   
    event LogValidateAndExecute (uint _CycleNumber,  uint _Amount, address indexed _InvestorAddress, address _ReferrerAddress, address _by);   
    
    event LogVaultAddressChanged(address indexed _ValultAddress, address _by);

    
    constructor() public {
        AdminsArray.push(msg.sender);
        isAdmin[msg.sender] = true;
    }
    
    
    modifier onlyAdmin(){
        require(isAdmin[msg.sender], "Config:: NOT_ADMIN");
        _;
    }
    
    modifier onlyAccountant(){
        require(isAccountant[msg.sender], "Config:: NOT_ACCOUNTANT");
        _;
    }
    
     modifier onlyKyc(){
        require(isKyc[msg.sender], "Config:: NO_KYC");
        _;
    }
    
    modifier addressValid(address _address) {
        require(_address != address(0), "Utils:: INVALID_ADDRESS");
        _;
    }
    
    function getAllAdmins()
        public
        view
        returns(address[] memory)
    {
        return AdminsArray;
    }

    function addAdmin
        (
            address _Admin
        )
            external
            onlyAdmin
            addressValid(_Admin)
        {   
            require(!isAdmin[_Admin], "Config::addAdmin ADMIN_ALREADY_EXISTS");
    
            AdminsArray.push(_Admin);
            isAdmin[_Admin] = true;
    
            emit LogAdminAdded(_Admin, msg.sender);
        }
    
    function removeAdmin
    (
        address _Admin
    ) 
        external
        onlyAdmin
        addressValid(_Admin)
    {   
        require(isAdmin[_Admin], "Config::removeAdmin ADMIN_DOES_NOT_EXIST");
        require(msg.sender != _Admin, "Config::removeAdmin ADMIN_NOT_AUTHORIZED");

        isAdmin[_Admin] = false;

        for (uint i = 0; i < AdminsArray.length - 1; i++) {
            if (AdminsArray[i] == _Admin) {
                AdminsArray[i] = AdminsArray[AdminsArray.length - 1];
                AdminsArray.length -= 1;
                break;
            }
        }

        emit LogAdminRemoved(_Admin, msg.sender);
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
            onlyAdmin
        {   
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
        onlyAdmin
    {   
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
    
    
    function getAllKycs()
        public
        view
        returns(address[] memory)
    {
        return KycArray;
    }

    function addKyc
        (
            address _Kyc
        )
            external
            onlyAdmin
            addressValid(_Kyc)
        {   
            require(!isKyc[_Kyc], "Proxy::addKyc KYC_ALREADY_EXISTS");
    
            KycArray.push(_Kyc);
            isKyc[_Kyc] = true;
    
            emit LogKycAdded(_Kyc, msg.sender);
        }
    
    function removeKyc
    (
        address _Kyc
    ) 
        external
        onlyAdmin
        addressValid(_Kyc)
    {   
        require(isKyc[_Kyc], "Proxy::removeKyc KYC_DOES_NOT_EXIST");
       

        isAdmin[_Kyc] = false;

        for (uint i = 0; i < KycArray.length - 1; i++) {
            if (KycArray[i] == _Kyc) {
                KycArray[i] = KycArray[KycArray.length - 1];
                KycArray.length -= 1;
                break;
            }
        }

        emit LogKycRemoved(_Kyc, msg.sender);
    }
    
   
   
   
     function getAllTokenAddresses()
        public
        view
        returns(address[] memory)
    {
        return TokenAddressArray;
    }

    function addTokenAddress
        (
           uint _CycleNumber,
           address _TokenAddress
        )
            external
            onlyAdmin
            addressValid(_TokenAddress)
        {   
            require(!isTokenAddress[_TokenAddress], "Proxy::addTokenAddress TokenAddress_ALREADY_EXISTS");
    
            TokenAddressArray.push(_TokenAddress);
            isTokenAddress[_TokenAddress] = true;
            tokenAddress[_CycleNumber] = _TokenAddress;
            cycleNumber[_TokenAddress] = _CycleNumber;
    
            emit LogTokenAddressAdded(_CycleNumber, _TokenAddress, msg.sender);
        }
    
    function removeTokenAddress
    (
        uint _CycleNumber,
        address _TokenAddress
    ) 
        external
        onlyAdmin
        addressValid(_TokenAddress)
    {   
        require(isTokenAddress[_TokenAddress], "Proxy::removeTokenAddress TokenAddresse_DOES_NOT_EXIST");
       

        isTokenAddress[_TokenAddress] = false;
        tokenAddress[_CycleNumber] = address(0);

        for (uint i = 0; i < TokenAddressArray.length - 1; i++) {
            if (TokenAddressArray[i] == _TokenAddress) {
                TokenAddressArray[i] = TokenAddressArray[TokenAddressArray.length - 1];
                TokenAddressArray.length -= 1;
                break;
            }
        }

        emit LogTokenAddressRemoved(_CycleNumber, _TokenAddress, msg.sender);
    }
    
    
    
     function getAllVaultAddresses()
        public
        view
        returns(address[] memory)
    {
        return VaultAddressArray;
    }

    function addVaultAddress
        (
           address _VaultAddress
        )
            external
            onlyAdmin
            addressValid(_VaultAddress)
        {   
            require(!isVaultAddress[_VaultAddress], "Proxy::addVaultAddress VaultAddress_ALREADY_EXISTS");
    
            VaultAddressArray.push(_VaultAddress);
            isVaultAddress[_VaultAddress] = true;
    
            emit LogVaultAddressAdded( _VaultAddress, msg.sender);
        }
    
    function removeVaultAddress
    (
        address _VaultAddress
    ) 
        external
        onlyAdmin
        addressValid(_VaultAddress)
    {   
        require(isVaultAddress[_VaultAddress], "Proxy::removeVaultAddress VAULT_ADDRESS_DOES_NOT_EXIST");
       

        isVaultAddress[_VaultAddress] = false;

        for (uint i = 0; i < VaultAddressArray.length - 1; i++) {
            if (VaultAddressArray[i] == _VaultAddress) {
                VaultAddressArray[i] = VaultAddressArray[VaultAddressArray.length - 1];
                VaultAddressArray.length -= 1;
                break;
            }
        }

        emit LogVaultAddressRemoved( _VaultAddress, msg.sender);
    }
    
    

    function updateLockingEndtime
        (
            uint _CycleNumber,
            uint _LockingEndTime
        )
            external
            onlyAdmin
        {   
    
            lockingEndTime[_CycleNumber] = _LockingEndTime;
            emit LogLockingEndTimeupdated(_CycleNumber, _LockingEndTime, msg.sender);
        }
    

    function updateCycleStartTime
        (
            uint _CycleNumber,
            uint _CycleStartTime
        )
            external
            onlyAdmin
        {   
    
            cycleStartTime[_CycleNumber] = _CycleStartTime;
            emit LogCycleStartTimeupdated(_CycleNumber, _CycleStartTime, msg.sender);
        }
        
        
  function updateVaultAddressForAccountant
    (
    address _ValultAddress,
    address _AccountantAddress
    )
    public
    onlyAdmin
    {
       AccountantVaultAddress[_AccountantAddress] = _ValultAddress; 
       emit LogAccountantVaultAddressUpdated(_ValultAddress, _AccountantAddress, msg.sender);
    }
   
   
    
    function validateAndExecute 
        (
        uint _CycleNumber, 
        uint _Amount,
        address _InvestorAddress,
        address _ReferrerAddress
        )
        external
        onlyAccountant
        addressValid(_InvestorAddress)
        {
        require(_InvestorAddress != _ReferrerAddress, "Proxy::ValidateAndExecute investor equals Referrer");
        require((uint(100000)).sub(cycleLimit[_InvestorAddress][_CycleNumber]) >=_Amount, "Proxy::ValidateAndExecute cycle limit reached");
        if (_ReferrerAddress != address(0))
        {       
            transferBalance[_InvestorAddress] = transferBalance[_InvestorAddress].add(_Amount);
            referrerLimit[_InvestorAddress] = referrerLimit[_InvestorAddress].add(_Amount.div(10));
            cycleLimit[_InvestorAddress][_CycleNumber] = cycleLimit[_InvestorAddress][_CycleNumber].add(_Amount);
            if (referrerLimit[_ReferrerAddress] >= _Amount.div(10))
                {
                    transferBalance[_ReferrerAddress] = transferBalance[_ReferrerAddress].add(_Amount.div(10));
                    referrerLimit[_ReferrerAddress] = referrerLimit[_ReferrerAddress].sub(_Amount.div(10));
                }
            else 
                {
                    transferBalance[_ReferrerAddress].add(referrerLimit[_ReferrerAddress]);
                
                }
        }
        else
        {
            transferBalance[_InvestorAddress] = transferBalance[_InvestorAddress].add(_Amount);
            referrerLimit[_InvestorAddress] = referrerLimit[_InvestorAddress].add(_Amount.div(10));
        }
        
        emit LogValidateAndExecute ( _CycleNumber,  _Amount,  _InvestorAddress,  _ReferrerAddress, msg.sender );
    }
    
    function updateTransferBalance
    (
       address _To, 
       uint _Amount 
    )
    public 
    {
       require( isVaultAddress[msg.sender], "proxy:: UpdateTransferBalance VAULT_NOT_AUTHORIZED" );
       transferBalance[_To] = transferBalance[_To].sub(_Amount);
        
    }
}
    
