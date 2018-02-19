const Promise = require("bluebird");
Promise.promisifyAll(web3.eth, { suffix: "Promise" });
const Splitter = artifacts.require("./Splitter.sol");

contract('Splitter', function(accounts) {
  const aliceAddress = accounts[0];
  const bobAddress = accounts[1];
  const carolAddress = accounts[2];

  let splitterContractInstance;

    // Deploy a contract(s) and prepare it up
    // to the pass / fail point
  before("deploy and prepare", function() {
    console.log("running before");
    return Splitter.new(bobAddress, carolAddress, {from:aliceAddress})
      .then(instance => {
        splitterContractInstance = instance;
        console.log("splitter initialized");
      });
  });

  it("should send coin correctly", function() {
    console.log("running 'should send coin correctly' test");
    console.log("contract address: " + splitterContractInstance.address);

    var amount = 999;
    var bobAmount = Math.floor(amount / 2);
    var carolAmount = amount - bobAmount;
    console.log("amount to split: " + amount);
    console.log("split amounts (bob,carol): (" + bobAmount + "," + carolAmount + ")");

    var contract_starting_balance;
    var bob_starting_balance;
    var carol_starting_balance;

    return web3.eth.getBalancePromise(splitterContractInstance.address)
    .then(balance => {
      contract_starting_balance = balance;
      console.log("Contract starting balance before split: " + contract_starting_balance);
      return splitterContractInstance.getBalanceBob.call();
    }).then(balance => {
      bob_starting_balance = balance;
      console.log("Bob starting balance before split: " + bob_starting_balance);
      return splitterContractInstance.getBalanceCarol.call();
    }).then(balance => {
      carol_starting_balance = balance;
      console.log("Carol starting balance before split: " + carol_starting_balance);
      console.log("sending first split");
      return splitterContractInstance.split({value:amount, gas:3000000});
    }).then(txResult => {
      console.log("success: " + (txResult !== null));
      assert(txResult !== null, "split was not successful");
      return splitterContractInstance.getBalanceBob.call();
    }).then(function(balance) {
      var bob_ending_balance = balance;
      console.log("Bob ending balance after split: " + bob_ending_balance);
      assert.strictEqual(bob_ending_balance.toString(10), bob_starting_balance.plus(bobAmount).toString(10), "Amount wasn't correctly sent to bob");
      return splitterContractInstance.getBalanceCarol.call();
    }).then(function(balance) {
      var carol_ending_balance = balance;
      assert.strictEqual(carol_ending_balance.toString(10), carol_starting_balance.plus(carolAmount).toString(10), "Amount wasn't correctly sent to carol");
      console.log("Carol ending balance after split: " + carol_ending_balance);
      return web3.eth.getBalancePromise(splitterContractInstance.address);
    }).then(function(balance) {
      var contract_ending_balance = balance;
      console.log("Contract ending balance after split: " + contract_ending_balance);
      assert.strictEqual(contract_ending_balance.toString(10), contract_starting_balance.plus(amount).toString(10), "Amount wasn't applied correctly to the contract");
    });
  });

  it("should withdraw coin correctly", function() {
    console.log("running 'should withdraw coin correctly' test");

    var bob_starting_balance;
    var contract_starting_balance;
    var amount_to_withdraw = 100;

    console.log("withdraw initialization");

    return web3.eth.getBalancePromise(splitterContractInstance.address)
    .then(balance => {
      contract_starting_balance = balance;
      console.log("Contract starting balance before withdraw: " + contract_starting_balance);
      return splitterContractInstance.getBalanceBob.call();
    }).then(balance => {
      bob_starting_balance = balance;
      console.log("Bob starting balance before withdraw: " + bob_starting_balance);
      console.log("sending bob withdraw");
      return splitterContractInstance.withdraw(amount_to_withdraw, {from: bobAddress });
    }).then(txObject => {
      console.log("withdraw successful");
      return splitterContractInstance.getBalanceBob.call();
    }).then(balance => {
      var bob_ending_balance = balance;
      console.log("Bob ending balance after withdraw: " + bob_ending_balance);
      assert.strictEqual(bob_ending_balance.toString(10), bob_starting_balance.minus(amount_to_withdraw).toString(10), "Amount wasn't correctly sent to bob");
    });
  });

  //TODO: More tests!
 });
