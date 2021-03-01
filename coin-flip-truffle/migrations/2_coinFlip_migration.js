const coinFlip = artifacts.require("coinFlip");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(coinFlip, {value: web3.utils.toWei("0.1", "ether")});
};
