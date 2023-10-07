// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '@openzeppelin/contracts/access/Ownable.sol';


/// @custom:security-contact theaveas.so@gmail.com
contract TSOXToken is ERC20, ERC20Burnable, AccessControl, Ownable{
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  mapping (address=>uint256) private _balances;

  uint256 private _totalSupply;

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  constructor () ERC20("TesoX", "TSOX") {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(MINTER_ROLE, msg.sender);
  }

  function mint(address _to, uint256 _amount) external onlyRole(MINTER_ROLE) {
    _totalSupply = _totalSupply.add(_amount);
    _balances[_to] = _balances[_to].add(_amount);
    _mint(_to, _amount);
  }

  function safeTsoXTransfer(address _to, uint256 _amount) external onlyRole(MINTER_ROLE) {
    uint256 tsoxBalance = balanceOf(address(this));
    if (_amount > tsoxBalance) {
      transfer(_to, tsoxBalance);
    } else {
      transfer(_to, _amount);
    }
  }

}
