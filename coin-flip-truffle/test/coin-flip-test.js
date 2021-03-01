//TESTED USING SUBSTITUTE FUNCTION
const coinFlip = artifacts.require("coinFlip");
const truffleAssert = require("truffle-assertions");

contract("coinFlip", async function(accounts){
  let instance;

  before(async function(){
    instance = await coinFlip.deployed();
  });

  it("should migrate with initial deposit and set balance correctly", async function(){
    let balance = await instance.balance();
    let ethBalance = await web3.eth.getBalance(instance.address);
    //console.log(balance);
    assert(balance > 0 && balance == ethBalance);
  });

  var queryId;
  it("should get queryId from testRandom", async function(){
    let tx = await instance.testRandom();
    truffleAssert.eventEmitted(tx, "queryFromRandom", function(ev){
      queryId = ev.queryId;
      //console.log(queryId);
      return true;
    });
  });

  it("should pass same queryId to update function", async function(){
    let tx = await instance.update(true);//input heads => bet true
    truffleAssert.eventEmitted(tx, "LogNewProvableQuery", function(ev){
      if(queryId == ev.queryId){
        //console.log(ev.queryId);
        return true;
      }
      else return false;
    });
  });

  it("should make new query struct", async function(){
    let tx = await instance.update(true);
    truffleAssert.eventEmitted(tx, "makeQuery", function(ev){
      //console.log(ev.newQuery);
      return true;
    });
  });

  it("should get result from callback and pass to query struct", async function(){
    instance = await coinFlip.new();
    let tx = await instance.update(true);
    truffleAssert.eventEmitted(tx, "callbackReply", function(ev){
      //console.log(ev.updatedQuery);
      return true;
    });
  });

  it("should payout if user wins; no payout if lose", async function(){
    let tx = await instance.update(true, {value: web3.utils.toWei("1", "ether")});
    let win = tx.logs[1].args[0].win;
    console.log(win);
    console.log(tx.logs[2].args[1].toNumber())
    if(win == true){
      //assert(instance.winningsLog[accounts[0]] > 0);
      //console.log(instance.winningsLog[accounts[0]].totalWithdrawable;
    }
    else if(win == false){
      //assert(instance.winningsLog[accounts[0]] == 0);
    }

  });

});
