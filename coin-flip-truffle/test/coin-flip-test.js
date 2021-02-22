const coinFlip = artifacts.require("coinFlip");
const truffleAssert = require("truffle-assertions");

contract("coinFlip", async function(){
  let instance;

  before(async function(){
    instance = await coinFlip.deployed();
  });

  var queryId;
  it("should get queryId from testRandom", async function(){
    let tx = await instance.testRandom();
    truffleAssert.eventEmitted(tx, "queryFromRandom", function(ev){
      queryId = ev.queryId;
      console.log(queryId);
      return true;
    });
  });

  it("should pass same queryId to update function", async function(){
    let tx = await instance.update(true);//input heads => bet true
    truffleAssert.eventEmitted(tx, "LogNewProvableQuery", function(ev){
      if(queryId == ev.queryId){
        console.log(ev.queryId);
        return true;
      }
      else return false;
    });
  });

  it("should make new query struct", async function(){
    let tx = await instance.update(true);
    truffleAssert.eventEmitted(tx, "makeQuery", function(ev){
      console.log(ev.newQuery);
      return true;
    });
  });

  it("should get result from callback and pass to query struct", async function(){
    let tx = await instance.update(true);
    truffleAssert.eventEmitted(tx, "callbackReply", function(ev){
      console.log(ev.updatedQuery);
      return true;
    });
  });

});
