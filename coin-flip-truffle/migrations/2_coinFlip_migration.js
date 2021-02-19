const coinFlip = artifacts.require("coinFlip");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(coinFlip);


  /*
  , {from: accounts[1]}));
  .then(function(instance){
    instance.deposit({value: web3.utils.toWei("0.00000000005", "ether"), from: accounts[1]});
  });
  */
};
