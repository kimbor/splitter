const Promise = require("bluebird");
Promise.promisifyAll(web3.eth, { suffix: "Promise" });
const Remittance = artifacts.require("./Remittance.sol");

contract('Remittance', function(accounts) {
  const alice = accounts[1];
  const bob = accounts[2];
  const carol = accounts[0];
  const passwordBob = "passwordBob";
  const passwordCarol = "passwordCarol";
  const amount_to_remit = 1000000000;

  let remitContractInstance;

    // Deploy a contract(s) and prepare it up
    // to the pass / fail point
  before("deploy and prepare", function() {
    console.log("running before");
    return Remittance.new({from:alice})
      .then(instance => {
        remitContractInstance = instance;
        console.log("Remittance contract initialized");
      });
  });

  it("should send coin correctly", function() {
    console.log("running 'should send coin correctly' test");
    console.log("contract address: " + remitContractInstance.address);

    console.log("amount for alice to send: " + amount_to_remit);

    var contract_starting_balance;
    var alice_starting_balance;
    var bob_starting_balance;
    var carol_starting_balance;

    return web3.eth.getBalancePromise(remitContractInstance.address)
    .then(balance => {
      contract_starting_balance = balance;
      console.log("Contract starting balance before send: " + contract_starting_balance);
      assert(contract_starting_balance == 0, "contract initially has no value");
      return remitContractInstance.sendRemittance(passwordBob, passwordCarol, {value:amount_to_remit, gas:3000000, from:alice});
    }).then(txResult => {
      console.log("success: " + (txResult.logs[0].event !== null));
      assert(txResult !== null, "remittance send was not successful");
      console.log(txResult);
      return web3.eth.getBalancePromise(remitContractInstance.address);
    }).then(function(balance) {
      var contract_ending_balance = balance;
      console.log("Contract ending balance after send: " + contract_ending_balance);
      assert.strictEqual(contract_ending_balance.toString(10), contract_starting_balance.plus(amount_to_remit).toString(10), "Amount wasn't applied correctly to the contract");
    });
  });

  it("should receive coin correctly", function() {
    console.log("running 'should receive coin correctly' test");

    var bob_starting_balance;
    var contract_starting_balance;
    var gasUsed;

    return web3.eth.getBalancePromise(remitContractInstance.address)
    .then(balance => {
      contract_starting_balance = balance;
      console.log("Contract balance before withdraw: " + contract_starting_balance);
      return web3.eth.getBalancePromise(bob);
    }).then(balance => {
      bob_starting_balance = balance;
      console.log("Bob balance before withdraw: " + bob_starting_balance);
      console.log("sending bob withdraw");
      return remitContractInstance.receiveRemittance(passwordBob, passwordCarol, {gas:3000000, from: bob});
    }).then(txObject => {
      console.log("withdraw successful");
      console.log(txObject);
      gasUsed = txObject.receipt.gasUsed;
      console.log("Gas used: " + gasUsed);
      return web3.eth.getBalancePromise(bob);
    }).then(balance => {
      var bob_ending_balance = balance;
      console.log("Bob balance after withdraw: " + bob_ending_balance);
      assert.strictEqual(bob_ending_balance.toString(10), bob_starting_balance.plus(amount_to_remit).minus(gasUsed*100000000000).toString(10), "Amount wasn't correctly sent to bob");
      return web3.eth.getBalancePromise(remitContractInstance.address)
    }).then(balance => {
      var contract_ending_balance = balance;
      console.log("Contract balance after withdraw: " + contract_ending_balance);
      assert.strictEqual(contract_ending_balance.toString(10), "0", "Amount wasn't debited from contract");
    });
  });
 });
