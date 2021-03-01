import "./provableAPI.sol";
import "./Ownable.sol";
pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;

contract coinFlip is Ownable, usingProvable
{
  address public contractAddress = address(this);
  uint public balance;

  //FOR RANDOM FUNCTION
  uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1;

  struct playerInfo{
    bool isPlaying;
    uint256 totalWithdrawable;
  }

  struct Query {
    address player;
    bool bet;
    uint256 betAmount;
    bool isHeads;
    bool win;
    bool isUpdating;
  }

  mapping(bytes32 => Query) public queryLog;
  mapping(address => playerInfo) public playerLog;

  //EVENTS
  event LogNewProvableQuery(string description, bytes32 indexed queryId);
  //event queryFromRandom(bytes32 queryId);
  event generatedRandomFlip(bool randomFlip);
  event makeQuery(string description, Query indexed newQuery);//not usable web3.js cannot display struct
  event callbackReply(Query indexed updatedQuery);//not usable web3.js cannot display struct
  event flipResult(string description);
  event payoutSuccess(string description, uint256 newTotalWinnings);


  constructor() payable public{
    balance = msg.value;
  }

  function getBalance() public view returns(uint){
    assert(balance == address(this).balance);
    return(address(this).balance);
  }

  function deposit() public payable onlyOwner returns(uint){
    balance += msg.value;
    assert(balance == address(this).balance);
    return(balance);
  }

  function update(bool bet) payable public {
    require(msg.value > 0 && msg.value <= balance && playerLog[msg.sender].isPlaying == false
    ,"Bet amount must be greater than 0 or Contract balance insufficient or Player is in play");
    balance += msg.value; //update balance after function call
    uint fee = provable_getPrice("random");
    uint256 QUERY_EXECUTION_DELAY = 0; // NOTE: The datasource currently does not support delays > 0!
    uint256 GAS_FOR_CALLBACK = 200000;
    bytes32 queryId = provable_newRandomDSQuery(
        QUERY_EXECUTION_DELAY,
        NUM_RANDOM_BYTES_REQUESTED,
        GAS_FOR_CALLBACK
    );
    balance -= fee; // subtract fee after oracle function call by contract
    //bytes32 queryId = testRandom();
    //Input values to Query struct
    queryLog[queryId].player = msg.sender;
    queryLog[queryId].bet = bet;
    queryLog[queryId].betAmount = msg.value - fee;
    queryLog[queryId].isUpdating = true;
    playerLog[msg.sender].isPlaying = true;

    emit LogNewProvableQuery("Provable query was sent, standing by for the answer, queryId for this flip: ", queryId);
    emit makeQuery("Current flip details: ", queryLog[queryId]);
  }

  //substitute function
  /*
  function testRandom() public returns(bytes32) {
    bytes32 queryId = bytes32(keccak256(abi.encodePacked(msg.sender)));
    __callback(queryId, "1", bytes("test"));
    //EVENTS
    emit queryFromRandom(queryId);
    return queryId;
  }
  */

  function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public {
    require(msg.sender == provable_cbAddress());
    uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 2;

    //Convert number to bool; true= heads, false = tails
    bool randomFlip;
    if(randomNumber == 1){
      randomFlip = true;
    }
    else randomFlip = false;
    queryLog[_queryId].isHeads = randomFlip;
    //Event for testing
    emit generatedRandomFlip(randomFlip);

    //Check player choice against result
    if(randomFlip == queryLog[_queryId].bet){
      queryLog[_queryId].win = true;
      payout(_queryId);
      emit flipResult("You win!");
    }
    else {
      queryLog[_queryId].win = false;
      emit flipResult("You lose!");
    }
    queryLog[_queryId].isUpdating = false;
    playerLog[msg.sender].isPlaying = false;
    emit callbackReply(queryLog[_queryId]);
  }

  //call if user wins
  function payout(bytes32 _queryId) private {
    require(queryLog[_queryId].win == true);
    playerLog[queryLog[_queryId].player].totalWithdrawable += (queryLog[_queryId].betAmount * 2);
    emit payoutSuccess("Successfully added to winnings", playerLog[queryLog[_queryId].player].totalWithdrawable);
  }

  function withdrawWinnings() public {
    require(playerLog[msg.sender].totalWithdrawable > 0);
    uint256 totalWinnings = playerLog[msg.sender].totalWithdrawable;
    balance -= totalWinnings;
    playerLog[msg.sender].totalWithdrawable = 0;
    msg.sender.transfer(totalWinnings);
    assert(balance == address(this).balance);
  }

  function withdrawFunds() public onlyOwner{
    balance = 0;
    msg.sender.transfer(address(this).balance);
    assert(balance == address(this).balance && address(this).balance == 0);
  }

  function destoryContract() public onlyOwner {
        selfdestruct(owner);
    }

/*
  function _random() internal view returns (bool) {
    return(now % 2 == 0);
  }

  function flip(bool _choice) public payable returns(bool, bool){
    require(msg.value > 0);
    balance += msg.value;

    bool coin = _random();
    if(coin == _choice){
      //win
      balance -= msg.value*2;
      msg.sender.transfer(msg.value*2);
      assert(balance == address(this).balance);
      return(coin, true);
    }
    else{
      //lose
      assert(balance == address(this).balance);
      return(coin, false);
    }
  }
*/
}
