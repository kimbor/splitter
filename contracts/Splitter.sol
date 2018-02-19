pragma solidity ^0.4.13;

contract Splitter {
	address public owner;
	address bob;
	address carol;
	uint bobBalance;
	uint carolBalance;

	event LogTransfer(address indexed _from, address indexed _to, uint256 _value);
	event LogWithdraw(address indexed _to, uint256 _value);

	function Splitter(address _bob, address _carol) public payable {
		require (_bob != 0);
		require (_carol != 0);	
		owner = msg.sender;
		bob = _bob;
		carol = _carol;
	}

	function split() payable public returns(bool sufficient) {
		require(bob != 0);
		require(carol != 0);
		require(msg.value > 0);
		uint splitAmount = msg.value / 2;
		bobBalance += splitAmount;
		LogTransfer(msg.sender, bob, splitAmount);
		carolBalance += (msg.value - splitAmount);
		LogTransfer(msg.sender, carol, splitAmount);
		return true;
	}

	function getBalanceBob() public constant returns(uint) {
		return bobBalance;
	}
	function getBalanceCarol() public constant returns(uint) {
		return carolBalance;
	}

	function withdraw(uint amount) public {
		require(amount > 0);
		require(msg.sender == bob || msg.sender == carol);
		LogWithdraw(msg.sender, amount);

		if (msg.sender == bob) {
			bobBalance -= amount;
			bob.transfer(amount);
		}
		else if (msg.sender == carol) {
			carolBalance -= amount;
			carol.transfer(amount);
		}
	}

	// TODO: selfdestruct is a nasty solution that's almost always sub-optimal. 
	// It creates sinks where money can go but no function exists to pull it out. 
	// It's almost always better to have a run switch / pause switch and a modifier onlyIfRunning. 
	// That way, if the owner decides to halt the contract, all the functions 
	// will start throwing/reverting and, importantly, returning funds sent.
    function killMe() public returns (bool) {
        require(msg.sender == owner);
        selfdestruct(owner);
        return true;
    }

}
