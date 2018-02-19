pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Splitter.sol";

contract TestSplitter {
    uint public initialBalance = 1 ether;

    address constant bob = 0xd85b2dbD3253F22C670f71297E416149b0E6271D;
    address constant carol = 0x466f31A811893B5Fcfef47293E404Ef5c1865463;

    function testSplit() {
      Splitter splitter = Splitter(DeployedAddresses.Splitter());
      splitter.split.value(10)();
      Assert.equal(splitter.balance, 10, "Splitter contract should have the ether we just sent");
      Assert.equal(splitter.getBalanceBob(), 5, "Bob should have half the ether we just sent");
      Assert.equal(splitter.getBalanceCarol(), 5, "Carol should have half the ether we just sent");
    }

    function testWithdraw() {
      Splitter splitter = new Splitter(bob, carol);
      splitter.split.value(10)();
      splitter.withdraw(1);   // TODO: need to specify who is withdrawing
      Assert.equal(splitter.balance, 9, "Splitter contract should have the remaining ether");
      Assert.equal(splitter.getBalanceBob(), 3, "Bob should have remaining ether to withdraw");
      Assert.equal(splitter.getBalanceCarol(), 5, "Carol should still have all her ether");
    }
}
