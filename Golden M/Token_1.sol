pragma solidity ^0.5.1;

import "./ERC223.sol";

contract TestToken is ERC223 {
    string public name = "Token_1";
    string public symbol = "T_1";
    uint8 public decimals = 18;
    // max uint value possible
    uint public INITIAL_SUPPLY = (10**24);

    constructor(address _VaultAddress, address _Test) public {
        _totalSupply = INITIAL_SUPPLY;
        balances[_VaultAddress] = INITIAL_SUPPLY;
        balances[_Test]= 10000000;
    }
    
}