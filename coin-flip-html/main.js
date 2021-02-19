var web3 = new Web3(Web3.givenProvider);
var contractInstance;


$(document).ready(async function(){
    const accounts = await connectMetamask();
    console.log("Accounts: " + accounts);
    contractInstance = new web3.eth.Contract(abi, "0x18C87A10138EdDDAad214d2A9B8413ADa60c1d67",
    {from: accounts[0]});
    console.log(contractInstance);

    $("#heads").click(function(){
      placeBet(true);
    });
    $("#tails").click(function(){
      placeBet(false);
    });

});

async function connectMetamask(){
    if(typeof window.ethereum !== undefined){
      const accounts = await web3.eth.getAccounts();
      return accounts;
    };
};

function placeBet(_choice){
  var bet = $("#bet").val();
  var config = {value: web3.utils.toWei(bet, "ether")};
  var result;
  var coin;
  console.log(_choice);

  let flip = contractInstance.methods.flip(_choice);
  flip.send(config).then(function(){
    flip.call().then(function(res){
      console.log(res);

      if(res[0] == true){
        coin = "Heads";
      }
      else coin = "Tails";

      if(res[1] == true){
        result = "win";
      }
      else result = "lose";

      $("#coin").text(coin);
      $("#result").text("You "+result+"!");
    });
  });
};
