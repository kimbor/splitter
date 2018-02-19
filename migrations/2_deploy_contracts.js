var Splitter = artifacts.require("./Splitter.sol");

const bobAddress = web3.eth.accounts[1];
const carolAddress = web3.eth.accounts[2];

module.exports = function(deployer) {
  deployer.deploy(Splitter, bobAddress, carolAddress, {gas:400000});
};
