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
      Splitter splitter = Splitter(DeployedAddresses.Splitter());
      splitter.split.value(10)();
      splitter.withdraw(1);   // TODO: need to specify who is withdrawing
        // Xavier wrote: When you write that, this test contract is the one asking to withdraw. 
        // This is not going to fly because this test contract is neither bob nor carol.
        // You would need to do new Splitter(this, carol).
      Assert.equal(splitter.balance, 9, "Splitter contract should have the remaining ether");
      Assert.equal(splitter.getBalanceBob(), 3, "Bob should have remaining ether to withdraw");
      Assert.equal(splitter.getBalanceCarol(), 5, "Carol should still have all her ether");

      // when splitter.withdraw(1) line above is present, truffle reports that this test passes successfully.
      // code below should ensure that this test fails
      uint one = 1;
      Assert.equal(one, 2, "is testWithdraw being executed?");
    }
}
