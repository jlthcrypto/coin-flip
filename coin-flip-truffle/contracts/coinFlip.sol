//import "./provableAPI.sol";
import "./Ownable.sol";
pragma solidity 0.5.12;

contract coinFlip is Ownable
//, usingProvable
{

  address public contractAddress = address(this);
  uint public balance;

  //FOR RANDOM FUNCTION
  uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1;
  struct Query {
    address payable player;
    bool isHeads;
  }

  mapping(bytes32 => Query) public queryLog;

  event LogNewProvableQuery(string description);
  event generatedRandomFlip(bool randomFlip);

  constructor() public {
    update();
  }

  function update() payable public {
    /*  Comment out to use oracle
    uint256 QUERY_EXECUTION_DELAY = 0; // NOTE: The datasource currently does not support delays > 0!
    uint256 GAS_FOR_CALLBACK = 200000;
    bytes32 queryId = provable_newRandomDSQuery(
        QUERY_EXECUTION_DELAY,
        NUM_RANDOM_BYTES_REQUESTED,
        GAS_FOR_CALLBACK
    );
    */
    bytes32 queryId = testRandom();
    queryLog[queryId].player = msg.sender;
    emit LogNewProvableQuery("Provable query was sent, standing by for the answer...");
  }

  //substitute function
  function testRandom() public returns(bytes32) {
    bytes32 queryId = bytes32(keccak256(abi.encodePacked(msg.sender)));
    __callback(queryId, "1", bytes("test"));
    return queryId;
  }

  function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public {
    //require(msg.sender == provable_cbAddress());
    uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 2;

    bool randomFlip;
    if(randomNumber == 1){
      randomFlip = true;
    }
    else randomFlip = false;

    queryLog[_queryId].isHeads = randomFlip;
    emit generatedRandomFlip(randomFlip);
  }

  function deposit() public payable onlyOwner returns(uint){
    balance += msg.value;
    assert(balance == address(this).balance);
    return(balance);
  }

  function getBalance() public view returns(uint){
    assert(balance == address(this).balance);
    return(address(this).balance);
    }

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

}
