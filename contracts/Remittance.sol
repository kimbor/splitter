pragma solidity ^0.4.13;

contract Remittance {
	address public owner;

	struct Escrow {
		address sender;		// Alice
		uint amount;		// amount of ether that Alice sent
	}

	// map a hash of Bob's and Carol's password to our Escrow struct
	mapping(bytes32=>Escrow) public balances;

	event LogSend(address indexed sender, uint value);
	event LogReceive(address indexed _to, uint256 _value);

	function Remittance() public {
		owner = msg.sender;
	}

	function getHash(bytes32 passwordBob, bytes32 passwordCarol) returns(bytes32) {
		return keccak256(passwordBob, passwordCarol);
	}

	/**
	* Alice uses sendRemittance to send eth to the contract.
	*/
 	function sendRemittance(bytes32 passwordBob, bytes32 passwordCarol) payable public returns(bool success){
 		require(msg.value > 0);
 		require(passwordBob != 0);
 		require(passwordCarol != 0);
 		bytes32 pwHash = getHash(passwordBob, passwordCarol);
 		balances[pwHash] = Escrow(msg.sender, msg.value);
 		LogSend(msg.sender, msg.value);
 		return true;
	}

	function receiveRemittance(bytes32 passwordBob, bytes32 passwordCarol) public returns (uint amount) {
		bytes32 pwHash = getHash(passwordBob, passwordCarol);
		var escrow = balances[pwHash];
		msg.sender.transfer(escrow.amount);
		LogReceive(msg.sender, escrow.amount);
		return escrow.amount;
	}
}
