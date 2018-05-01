pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/token/ERC20/PausableToken.sol";
import "zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

contract NToken is PausableToken, BurnableToken {
  using SafeMath for uint;

  string public constant name = 'N Token';
  string public constant symbol = 'NEX';
  uint8 public constant decimals = 18;

  uint256 private constant TOKEN_UNIT = 10 ** uint256(decimals);
  uint public startTime;
  address public crowdsaleAddress;

  constructor() public {
    startTime = now + 365 days;
    totalSupply_ = 200000000 * TOKEN_UNIT;
    balances[owner] = totalSupply_;
    emit Transfer(address(0), owner, totalSupply_);
  }

  function totalSupply() public constant returns (uint) {
    return totalSupply_.sub(balances[address(0)]);
  }

  function burnFrom(address _from, uint256 _value) onlyOwner public {
    _burn(_from, _value);
  }

  function setCrowdsaleAddress(address _crowdsaleAddress) external onlyOwner {
    crowdsaleAddress = _crowdsaleAddress;
    assert(approve(crowdsaleAddress, publicAmount));
  }

  function setStartTime(uint _startTime) external {
    require(msg.sender == crowdsaleAddress);
    if(_startTime < startTime) {
      startTime = _startTime;
    }
  }

  function transfer(address _to, uint _value) public returns (bool) {
    // Only possible after ICO ends
    require(now >= startTime);
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) public returns (bool) {
    // Only owner's tokens can be transferred before ICO ends
    if (now < startTime) {
      require(_from == owner);
    }

    return super.transferFrom(_from, _to, _value);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(now >= startTime);
    super.transferOwnership(newOwner);
  }

  /* Do not accept ETH */
  function () public payable {
    revert();
  }

  /* Owner can transfer out any accidentally sent ERC20 tokens */
  function transferAnyERC20Token(address _tokenAddress, uint _tokens) public onlyOwner returns (bool success) {
    return ERC20(_tokenAddress).transfer(owner, _tokens);
  }
}