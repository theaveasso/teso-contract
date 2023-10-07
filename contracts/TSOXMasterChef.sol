// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./TSOXToken.sol";

/// @custom:security-contact theaveas.so@gmail.com
contract TSOXMasterChefV1 is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  struct UserInfo {
    uint256 amount;
    uint256 pendingReward;
  }

  struct PoolInfo {
    IERC20  lpToken;
    uint256 allocPoint;
    uint256 lastRewardBlock;
    uint256 rewardTokenPerShare;
  }

  TSOXToken public tsox;
  address public dev;
  uint256 public tsoxPerBlock;
  uint256 public totalAllocPoint = 0;

  uint256 public START_BLOCK;
  uint256 public BONUS_MULTIPLIER;

  mapping (uint256 => mapping (address=>UserInfo)) public userInfo;

  PoolInfo[] public poolInfo;

  constructor (
    TSOXToken _tsox,
    address _dev, 
    uint256 _tsoxPerBlock,
    uint256 _startBlock,
    uint256 _multiplier
  ) {
    tsox = _tsox;
    dev = _dev;
    tsoxPerBlock = _tsoxPerBlock;
    START_BLOCK = _startBlock;
    BONUS_MULTIPLIER = _multiplier;

    poolInfo.push(PoolInfo({
      lpToken: _tsox,
      allocPoint: 10000,
      lastRewardBlock: _startBlock,
      rewardTokenPerShare: 0
    }));

    totalAllocPoint = 10000;
  }

  function getPoolCount() external view returns(uint256) {
    return poolInfo.length;
  }

  function getPoolInfo(uint256 pid) public view returns(
    address lpToken, 
    uint256 allocPoint, 
    uint256 lastRewardBlock, 
    uint256 rewardTokenPerShare
  ){
    return (
      (address(poolInfo[pid].lpToken)),
      poolInfo[pid].allocPoint,
      poolInfo[pid].lastRewardBlock,
      poolInfo[pid].rewardTokenPerShare
    );
  }

  function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
    return _to.sub(_from).mul(BONUS_MULTIPLIER);
  }

  function updateMultiplier(uint256 bonusMuliplier) public onlyOwner {
    BONUS_MULTIPLIER = bonusMuliplier;
  } 

  modifier checkPoolDuplicate(IERC20 token) {
    uint256 length = poolInfo.length;
    for (uint256 _pid = 0; _pid < length; _pid ++) {
      require(poolInfo[_pid].lpToken != token, "Pool Already Exist");
    }
    _;
  }

  function updateStakingPool() internal {
    uint256 length = poolInfo.length;
    uint256 points = 0;
    for (uint256 _pid = 1; _pid < length; _pid++) {
      points = points.add(poolInfo[_pid].allocPoint);
    }
    if (points != 0) {
      points = points.div(3);
      totalAllocPoint = totalAllocPoint.sub(poolInfo[0].allocPoint).add(points);
      poolInfo[0].allocPoint = points;
    }
  }

  function addPool(uint256 _allocPoint, IERC20 _lptoken) public onlyOwner checkPoolDuplicate(_lptoken) {
    uint256 _lastRewardBlock = block.number > START_BLOCK ? block.number : START_BLOCK;
    totalAllocPoint = totalAllocPoint.add(_allocPoint);

    poolInfo.push(PoolInfo({
      lpToken: _lptoken,
      allocPoint: _allocPoint,
      lastRewardBlock: _lastRewardBlock,
      rewardTokenPerShare: 0
    }));

    updateStakingPool();
  }
}
