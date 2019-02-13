pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Remittance.sol";

contract TestRemittance {
    uint public initialBalance = 1 ether;

    address constant alice = 0x631d2e36285DC49F34a5b89570C988C2818bEBAF;
    address constant bob = 0xd85b2dbD3253F22C670f71297E416149b0E6271D;
    address constant carol = 0x466f31A811893B5Fcfef47293E404Ef5c1865463;
    bytes32 passwordBob = "passwordBob";
    bytes32 passwordCarol = "passwordCarol";

    function testSendRemittance() {
      Remittance remit = Remittance(DeployedAddresses.Remittance());
      remit.sendRemittance.value(10)(passwordBob, passwordCarol);
      Assert.equal(remit.balance, 10, "Remittance contract should have the ether we just sent");
      remit.receiveRemittance(passwordBob, passwordCarol);   // remittance is sent to the contract, since there doesn't seem to be any way to specify an alternate caller in this test framework
    }
}
