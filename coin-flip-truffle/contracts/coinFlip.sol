import "./Ownable.sol";
pragma solidity 0.5.12;

contract coinFlip is Ownable{

  address public contractAddress = address(this);
  uint public balance;

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
