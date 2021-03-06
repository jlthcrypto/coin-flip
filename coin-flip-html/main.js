var web3 = new Web3(Web3.givenProvider);
var contractInstance;
const contract = "0x0860696999baf41b9D433E329aa079669dB141f8"
$(document).ready(async function(){
    const accounts = await connectMetamask();
    contractInstance = new web3.eth.Contract(abi, contract, {from: accounts[0]});
    console.log(contractInstance);

    //Player Inputs
    $("#heads").click(function(){
      placeBet(true);
    });
    $("#tails").click(function(){
      placeBet(false);
    });
    $("#withdrawWinnings").click(function(){
      withdrawWinnings(accounts);
    });

    //Display Contract Balance
    let balance = await contractInstance.methods.getBalance().call();
    $("#contractBalance").text(web3.utils.fromWei(balance.toString(), "ether"));

    //Display Player Info
    $("#playerAddress").text(accounts[0]);
    let winnings = await contractInstance.methods.playerLog(accounts[0]).call();
    $("#playerWinnings").text(web3.utils.fromWei(winnings.totalWithdrawable.toString(), "ether"));

    //Events
    contractInstance.once("LogNewProvableQuery", function(error, event){
      $("#queryId").text(event.returnValues.queryId);
    });

    contractInstance.once("flipResult", async function(error,event){
      $("#result").text(event.returnValues.description)
      let winnings = await contractInstance.methods.playerLog(accounts[0]).call();
      $("#playerWinnings").text(web3.utils.fromWei(winnings.totalWithdrawable.toString(), "ether"));
      alert(event.returnValues.description);
    });

});

//Functions
async function connectMetamask(){
  if(typeof window.ethereum !== undefined){
    const accounts = await web3.eth.getAccounts();
    return accounts;
  };
};

function placeBet(_choice){
  var bet = $("#bet").val();
  var config = {value: web3.utils.toWei(bet, "ether")};

  //Call smart contract function
  let update = contractInstance.methods.update(_choice);
  update.send(config)
  .then(async function(){
    if(_choice == true){
      $("#choice").text("Heads");
    }
    else $("#choice").text("Tails");

    let balance = await contractInstance.methods.getBalance().call();
    $("#contractBalance").text(web3.utils.fromWei(balance.toString(), "ether"));
    $("#result").text("Waiting for result...")
    alert("Transaction pending");
  });
};

function withdrawWinnings(accounts){
  let withdrawWinnings = contractInstance.methods.withdrawWinnings();
  withdrawWinnings.send()
  .then(async function(){
    let balance = await contractInstance.methods.getBalance().call();
    $("#contractBalance").text(web3.utils.fromWei(balance.toString(), "ether"));
    let winnings = await contractInstance.methods.playerLog(accounts[0]).call();
    $("#playerWinnings").text(web3.utils.fromWei(winnings.totalWithdrawable.toString(), "ether"));
  });
};

//Console only functions; intended for contract owner
function deposit(_amount){//Input deposit amount as string, ex.("0.5")
  let deposit = contractInstance.methods.deposit();
  var config = {value: web3.utils.toWei(_amount, "ether")};
  deposit.send(config)
  .then(async function(){
    let balance = await contractInstance.methods.getBalance().call();
    $("#contractBalance").text(web3.utils.fromWei(balance.toString(), "ether"));
  });
};

function withdrawFunds(){//Withdraws everything
  let withdrawFunds = contractInstance.methods.withdrawFunds();
  withdrawFunds.send()
  .then(async function(){
    let balance = await contractInstance.methods.getBalance().call();
    $("#contractBalance").text(web3.utils.fromWei(balance.toString(), "ether"));
  });
};
