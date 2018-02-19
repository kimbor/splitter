pragma solidity ^0.4.13;

contract Splitter {
	address public owner;
	mapping(address=>uint) public balances;

	event LogSplit(address indexed sender, address indexed receiver1, address indexed receiver2, uint value);
	event LogWithdraw(address indexed _to, uint256 _value);

	function Splitter() public {
		owner = msg.sender;
	}

	function split(address receiver1, address receiver2) payable public returns(bool sufficient) {
		require(receiver1 != 0);
		require(receiver2 != 0);
		require(msg.value > 0);

		uint splitAmount = msg.value / 2;
		balances[receiver1] += splitAmount;
		balances[receiver2] += (msg.value - splitAmount);
		LogSplit(msg.sender, receiver1, receiver2, msg.value);
		return true;
	}

	function getBalance(address add) public constant returns (uint) {
		return balances[add];
	}

	function withdraw(uint amount) public {
		require(amount > 0);
		require(balances[msg.sender] >= amount);
		LogWithdraw(msg.sender, amount);

		balances[msg.sender] -= amount;
		msg.sender.transfer(amount);
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
