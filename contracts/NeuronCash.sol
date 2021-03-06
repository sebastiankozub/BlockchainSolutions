pragma solidity ^0.4.23;


import "./SmartOakMintable.sol";


contract NeuronCash is SmartOakMintable {

    string public symbol = "NCH";
    string public name = "Neuron  Cash";
    uint8 public decimals = 2;
	address public fundationAddress;
	uint256 public tokensCreated;
	uint256 public constant TOKEN_INITIAL_AMOUNT = 10**10;
	uint256 public constant NUMBER_OF_SECONDR_IN_A_MONTH = 30*24*3600;
	mapping (address=>uint256 ) public lastTimeTaxPayed;
	constructor(address _foundationAddress) public {
		fundationAddress = _foundationAddress;
		owner = address(this);
		tokensCreated = now;
	}
	
	
	 function () {
		this.mint(fundationAddress,TOKEN_INITIAL_AMOUNT-totalSupply());
	}
	
	
    function burn(uint256 amount) public {
        require(balanceOf(msg.sender)>=amount);
		burnUsersFunds(amount,msg.sender);
    }

	/*
	  1% of users balance per month
	*/
	function getTaxAmount(address user) view public returns(uint256) {
	    uint256 lastPayed = tokensCreated;
		if(lastTimeTaxPayed[user]>lastPayed){
			lastPayed=lastTimeTaxPayed[user];
		}
		return super.balanceOf(user).mul(now-lastTimeTaxPayed[user]).div(NUMBER_OF_SECONDR_IN_A_MONTH).div(100);
	}

	/* substract tax from current balance */
	function  balanceOf(address user) view public returns(uint256) {
		return super.balanceOf(user)-getTaxAmount(user);
	} 
	    
		
	function transfer(address to,uint256 _value) public returns(bool){
        burnUsersFunds(getTaxAmount(msg.sender),msg.sender);
        burnUsersFunds(getTaxAmount(to),to);
        return super.transfer(to,_value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    
        burnUsersFunds(getTaxAmount(msg.sender),msg.sender);
        burnUsersFunds(getTaxAmount(_to),_to);
        burnUsersFunds(getTaxAmount(_from),_from);
        return super.transferFrom(_from, _to, _value);
    }

	function burnUsersFunds(uint256 amount,address person) private{
		
        totalSupply_ = totalSupply_.sub(amount);
        balances[person] = balances[person].sub(amount);
		emit Transfer(person,address(0),amount);

		lastTimeTaxPayed[person]=now;
	}
}
