pragma solidity ^0.5.1;

import "./ERC223.sol";
import "./Proxy.sol";


contract coin is ERC223 {
    
    Proxy proxy;
    
    
    string public name = "G_M_C";
    string public symbol = "G_M";
    uint8 public decimals = 18;
    
    
    // max uint value possible
    uint public INITIAL_SUPPLY = 73440000;
    
    event LogTokenFallBack (address _from, uint _value);

    constructor(address _ProxyAddress) public {
        proxy = Proxy(_ProxyAddress);
        _totalSupply = INITIAL_SUPPLY;
        balances[address(this)] = INITIAL_SUPPLY;
    }
    
function tokenFallback(address _from, uint _value, bytes memory _data) public
{
    //check if msg.sender is the token contract 
    require((proxy.isTokenAddress(msg.sender)), "coin:: tokenFallback not a token address" );
    //check the Locking period of the token contract 
    require( now >= proxy.lockingEndTime(proxy.cycleNumber(msg.sender)) );
    //transfer the equivalent amount of coins to the account 
    this.transfer (_from, _value.div(100));
    
    emit LogTokenFallBack (_from, _value.div(100));

}
    
}
