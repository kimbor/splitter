pragma solidity ^0.4.2;

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
    }


  // function testInitialBalanceUsingDeployedContract() {
  //   Splitter splitter = Splitter(DeployedAddresses.Splitter());

    // uint expected = 10000;

    // Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  // }

  // function testInitialBalanceWithNewMetaCoin() {
  //   MetaCoin meta = new MetaCoin();

  //   uint expected = 10000;

  //   Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  // }

}
