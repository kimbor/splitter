var Promise = require("bluebird");
Promise.promisifyAll(web3.eth, { suffix: "Promise" });
var Splitter = artifacts.require("./Splitter.sol");

contract('Splitter', function(accounts) {
  console.log(accounts);
  var splitter;

  beforeEach("deploy and prepare", function() {
    console.log("running beforeEach");
    return Splitter.new(web3.eth.accounts[1], web3.eth.accounts[2], {from:web3.eth.accounts[0]})
      .then(instance => {
        splitter = instance;
        console.log("splitter initialized");
      });
  });
    // Deploy a contract(s) and prepare it up
    // to the pass / fail point

  it("should send coin correctly", function() {
    console.log("running 'should send coin correctly' test");
    console.log("contract address: " + splitter.address);

    var alice_starting_balance = web3.eth.getBalance(web3.eth.coinbase);
    console.log("Alice starting balance: " + alice_starting_balance.toString(10));

    var amount = 10;
    var splitAmount = amount / 2;

    var contract_starting_balance;
    var bob_starting_balance;
    var carol_starting_balance;

    // return Splitter.deployed().then(function(instance) {
    //   splitter = instance;
    return web3.eth.getBalancePromise(splitter.address)
    .then(balance => {
      contract_starting_balance = balance.toNumber();
      console.log("Contract starting balance: " + contract_starting_balance.toString(10));
      return splitter.getBalanceBob.call();
    }).then(balance => {
      bob_starting_balance = balance.toNumber();
      console.log("Bob starting balance: " + bob_starting_balance.toString(10));
      return splitter.getBalanceCarol.call();
    }).then(balance => {
      carol_starting_balance = balance.toNumber();
      console.log("Carol starting balance: " + carol_starting_balance.toString(10));
      console.log("sending first split");
      return splitter.split({value:amount, gas:3000000});
    }).then(success => {
      console.log("success: " + success.toString());
      assert(success, "split was not successful");
      return splitter.getBalanceBob.call();
    }).then(function(balance) {
      var bob_ending_balance = balance.toNumber();
      console.log("Bob ending balance: " + bob_ending_balance);
      assert.equal(bob_ending_balance, bob_starting_balance + splitAmount, "Amount wasn't correctly sent to bob");
      return splitter.getBalanceCarol.call();
    }).then(function(balance) {
      var carol_ending_balance = balance.toNumber();
      assert.equal(carol_ending_balance, carol_starting_balance + splitAmount, "Amount wasn't correctly sent to carol");
      console.log("Carol ending balance: " + carol_ending_balance);
      return web3.eth.getBalancePromise(splitter.address);
    }).then(function(balance) {
      var contract_ending_balance = balance.toNumber();
      console.log("Contract ending balance: " + contract_ending_balance.toString(10));
      assert.equal(contract_ending_balance, contract_starting_balance + amount, "Amount wasn't applied correctly to the contract");
    });
  });

/*
  it("should withdraw coin correctly", function() {
    console.log("running 'should withdraw coin correctly' test");

    var bob_starting_balance = 0;
    var bob_ending_balance;
    var amount_to_withdraw = 2;

    console.log("withdraw initialization");
    return Splitter.deployed().then(function(instance) {
      splitter = instance;
      return web3.eth.getBalancePromise(splitter.address);
    }).then(contract_starting_balance => {
      console.log("Contract starting balance: " + contract_starting_balance.toString(10));
      return splitter.getBalanceBob().call();
    }).then(bob_starting_balance => {
      console.log("Bob starting balance: " + bob_starting_balance.toNumber().toString(10));
      console.log("sending bob withdrawal");
      return splitter.withdraw(5, {from: web3.eth.accounts[1], gas:1000000});
    }).then(txObject => {
      assert.equal(bob_ending_balance, bob_starting_balance.minus(amount_to_withdraw), "Amount wasn't correctly sent to bob");
    });
  });
  */
 });
