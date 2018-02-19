pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Splitter.sol";

contract TestSplitter {
    address bob = 0xd85b2dbd3253f22c670f71297e416149b0e6271d;
    address carol = 0x466f31a811893b5fcfef47293e404ef5c1865463;

    function testSplit() {
      Splitter splitter = new Splitter(bob, carol);
      splitter.split.value(10)();
      Assert.equal(splitter.balance, 10, "Splitter contract should have the ether we just sent");
      Assert.equal(splitter.getBalanceBob(), 5, "Bob should have half the ether we just sent");
      Assert.equal(splitter.getBalanceCarol(), 5, "Carol should have half the ether we just sent");
      uint256 i = 1;
      Assert.equal(i, 2, "are these asserts even getting called?"); // this is NOT failing. why not?
    }

    function testWithdraw() {
      Splitter splitter = new Splitter(bob, carol);
      splitter.split.value(10)();
      splitter.withdraw(1);
      Assert.equal(splitter.balance, 9, "Splitter contract should have the remaining ether");
      Assert.equal(splitter.getBalanceBob(), 3, "Bob should have remaining ether to withdraw");
      Assert.equal(splitter.getBalanceCarol(), 5, "Carol should still have all her ether");
    }
}
