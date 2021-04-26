pragma solidity >=0.8.0;
//SPDX-License-Identifier: MIT

//import "hardhat/console.sol";

contract SimpleStream {

  event Withdraw( address indexed to, uint256 amount, string reason );
  event Deposit( address indexed from, uint256 amount, string reason );

  address payable public toAddress;// = payable(0xD75b0609ed51307E13bae0F9394b5f63A7f8b6A1);
  uint256 public cap;// = 0.5 ether;
  uint256 public frequency;// 1296000 seconds == 2 weeks;
  uint256 public last = block.timestamp - frequency; //stream starts full
  //uint256 public last = block.timestamp; //stream starts empty

  constructor(address payable _toAddress, uint256 _cap, uint256 _frequency, bool _startsFull) public {
    toAddress = _toAddress;
    cap = _cap;
    frequency = _frequency;
    if(_startsFull){
      last = block.timestamp - frequency;
    }else{
      last = block.timestamp;
    }
  }

  function streamBalance() public view returns (uint256){
    if(block.timestamp-last > frequency){
      return cap;
    }
    return (cap * (block.timestamp-last)) / frequency;
  }

  function streamWithdraw(uint256 amount, string memory reason) public {
       require(msg.sender==toAddress,"this stream is not for you");
       uint256 totalAmountCanWithdraw = streamBalance();
       require(totalAmountCanWithdraw>=amount,"not enough in the stream");
       last = last + ((block.timestamp - last) * amount / totalAmountCanWithdraw);
       emit Withdraw( msg.sender, amount, reason );
       toAddress.transfer(amount);
   }

   function streamDeposit(string memory reason) public payable {
      require(msg.value>=cap/10,"Not big enough, sorry.");
      emit Deposit( msg.sender, msg.value, reason );
    }

   receive() external payable { streamDeposit(""); }
}
