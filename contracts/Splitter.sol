pragma solidity ^0.4.13;

import "./ConvertLib.sol";

contract Splitter {
	address public owner;
	address bob;
	address carol;
	uint bobBalance;
	uint carolBalance;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Withdraw(address indexed _to, uint256 _value);

	function Splitter(address _bob, address _carol) public payable {
		owner = msg.sender;
		bob = _bob;
		carol = _carol;
	}

	function split() payable public returns(bool sufficient) {
		uint splitAmount = msg.value / 2;
		bobBalance += splitAmount;
		Transfer(msg.sender, bob, splitAmount);
		carolBalance += splitAmount;
		Transfer(msg.sender, carol, splitAmount);
		return true;
	}

	function getBalanceBob() returns(uint) {
		return bobBalance;
	}
	function getBalanceCarol() returns(uint) {
		return carolBalance;
	}

	function withdraw(uint amount) public {
		Withdraw(msg.sender, amount);

		if (msg.sender == bob) {
			bob.transfer(amount);
			bobBalance -= amount;
		}
		else if (msg.sender == carol) {
			carol.transfer(amount);
			carolBalance -= amount;
		}
		else throw;
	}

    function killMe() public returns (bool) {
        require(msg.sender == owner);
        selfdestruct(owner);
        return true;
    }

}
