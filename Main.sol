pragma solidity ^0.5.0;

/**
 * Url: https://ethbank.pro
 * Version: 1.0.0
 * @dev ETH Bank Decentralized private equity fund
 */
library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract Bank {

  using SafeMath for uint256;

  struct Investor {
    address owner;
    address inviter;
    bytes6  ownerCode;
    bytes6  inviterCode;
    uint256 investAmount;
    uint256 investTotalAmount;
    uint256 inviteCount;
    uint256 staticAmount;
    uint256 dynamicAmount;
    uint256 managerAmount;
    uint256 level;
    uint256 applicationTime;
    uint256 createTime;
  }

  address public owner;
  address public robot;
  uint256 public totalAmount;

  bool public isForbid = false;

  uint256 public investMinAmount = 0.1 ether;
  uint256 public investMaxAmount = 20 ether;
  uint256 public withdrawMinAmount = 0.1 ether;
  uint256 public withdrawMinInvestAmount = 0.1 ether;
  uint256 public investMinTotalAmount = 0.1 ether;

  uint256 public applicationTime = 5 days;

  uint256[] public v1 = [0.1 ether, 5.9 ether];
  uint256[] public v2 = [6 ether, 10.9 ether];
  uint256[] public v3 = [11 ether, 20 ether];

  Investor[] public investors;

  mapping (bytes6 => uint256) public inviteCodeToIndex;
  mapping (address => bytes6) public ownerToInviteCode;

  mapping (address => bool) public ownerToStatus;
  mapping (bytes6 => bool) public codeToStatus;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyRobot() {
    require(msg.sender == robot);
    _;
  }

  modifier beUsable() {
    require(isForbid == false);
    _;
  }

  event CreateInvestor(
    address investor,
    uint256 index,
    uint256 amount,
    address inviter,
    uint256 createTime
  );

  event AirdropInvestor(
    address investor,
    uint256 amount,
    uint256 createTime
  );

  event Withdraw(
    address indexed investor,
    uint256 withdrawType,
    uint256 amount,
    uint256 createTime
  );

  event Dividend(
    address investor,
    uint256 dividendType,
    uint256 amount,
    uint256 createTime
  );

  event TransferOwnership(
    address oldOwner,
    address newOwner,
    uint256 createTime
  );

  event TransferRobotship(
    address oldOwner,
    address newOwner,
    uint256 createTime
  );

  constructor (address _owner, address _robot) public {
    owner = _owner;
    robot = _robot;

    _updateInvestor(_owner, 'system', address(0), 'system', investMinTotalAmount);
  }

  function() external payable {}

  function transferOwnership(address _owner) external onlyOwner {
    require(_owner != address(0));
    emit TransferOwnership(owner, _owner, now);

    owner = _owner;
  }

  function transferRobotship(address _robot) external onlyOwner {
    require(_robot != address(0));
    emit TransferRobotship(robot, _robot, now);

    robot = _robot;
  }

  function invest(
    bytes6 _ownerCode,
    bytes6 _inviterCode
  ) external payable beUsable {
    require(codeToStatus[_inviterCode] == true);

    address inviter = investors[inviteCodeToIndex[_inviterCode]].owner;
    uint256 investTotalAmount = investors[inviteCodeToIndex[_inviterCode]].investTotalAmount;
    require(investTotalAmount >= investMinTotalAmount);
    _updateInvestor(msg.sender, _ownerCode, inviter, _inviterCode, msg.value);

    totalAmount = totalAmount.add(msg.value);
  }

  function _updateInvestor(
    address _owner,
    bytes6 _ownerCode,
    address _inviter,
    bytes6 _inviterCode,
    uint256 _amount
  ) private {
    require(
      _amount >= investMinAmount
        && _amount <= investMaxAmount
        && _amount.mod(investMinAmount) == 0
    );
    if (ownerToStatus[_owner] == false) {
      require(codeToStatus[_ownerCode] == false);
      uint256 level = _getInvestLevel(_amount);
      uint256 index = investors.push(
        Investor(_owner, _inviter, _ownerCode, _inviterCode, _amount, _amount, 0, 0, 0, 0, level, now, now)
      ).sub(1);

      inviteCodeToIndex[_ownerCode] = index;
      ownerToInviteCode[_owner] = _ownerCode;
      ownerToStatus[_owner] = true;
      codeToStatus[_ownerCode] = true;

      uint256 inviterIndex = inviteCodeToIndex[_inviterCode];
      uint256 inviteCount = investors[inviterIndex].inviteCount.add(1);
      investors[inviterIndex].inviteCount = inviteCount;

      emit CreateInvestor(_owner, index, _amount, _inviter, now);
    } else {
      uint256 ownerIndex = getInvestorIndex(_owner);
      uint256 amount = investors[ownerIndex].investAmount.add(_amount);
      uint256 _totalAmount = investors[ownerIndex].investTotalAmount.add(_amount);
      require(amount <= investMaxAmount);

      investors[ownerIndex].level = _getInvestLevel(amount);
      investors[ownerIndex].investAmount = amount;
      investors[ownerIndex].investTotalAmount = _totalAmount;
      address inviter = investors[ownerIndex].inviter;

      emit CreateInvestor(_owner, ownerIndex, _amount, inviter, now);
    }
  }

  function _getInvestLevel(uint256 _amount) private view returns (uint256) {
    uint256 level = 0;
    if (_amount >= v1[0] && _amount <= v1[1]) {
      level = 1;
    } else if (_amount >= v2[0] && _amount <= v2[1]) {
      level = 2;
    } else if (_amount >= v3[0] && _amount <= v3[1]) {
      level = 3;
    }
    return level;
  }

  function forbidContract(bool _isForbid) external onlyRobot {
    isForbid = _isForbid;
  }

  function dividend(
    uint256[] calldata _userIndexs,
    uint256[] calldata _staticAmounts,
    uint256[] calldata _dynamicAmounts,
    uint256[] calldata _managerAmounts
  )
    external
    onlyRobot
  {
    require(
      _staticAmounts.length == _userIndexs.length
      && _dynamicAmounts.length == _userIndexs.length
      && _managerAmounts.length == _userIndexs.length
    );

    for (uint256 i = 0; i < _userIndexs.length; i++) {
      uint256 index = _userIndexs[i];

      investors[index].staticAmount =
        investors[index].staticAmount.add(_staticAmounts[i]);
      investors[index].dynamicAmount =
        investors[index].dynamicAmount.add(_dynamicAmounts[i]);
      investors[index].managerAmount =
        investors[index].managerAmount.add(_managerAmounts[i]);

      address _owner = investors[index].owner;

      emit Dividend(_owner, 1, _staticAmounts[i], now);
      emit Dividend(_owner, 2, _dynamicAmounts[i], now);
      emit Dividend(_owner, 3, _managerAmounts[i], now);
    }
  }

  function withdrawStatic() external beUsable {
    uint256 inviterIndex = getInvestorIndex(msg.sender);
    uint256 staticAmount = investors[inviterIndex].staticAmount;

    require(staticAmount >= withdrawMinAmount);
    require(address(this).balance >= staticAmount);

    investors[inviterIndex].staticAmount = 0;
    msg.sender.transfer(staticAmount);
    emit Withdraw(msg.sender, 1, staticAmount, now);
  }

  function withdrawDynamic() external beUsable {
    uint256 inviterIndex = getInvestorIndex(msg.sender);
    uint256 dynamicAmount = investors[inviterIndex].dynamicAmount;

    require(dynamicAmount >= withdrawMinAmount);
    require(address(this).balance >= dynamicAmount);

    investors[inviterIndex].dynamicAmount = 0;
    msg.sender.transfer(dynamicAmount);
    emit Withdraw(msg.sender, 2, dynamicAmount, now);
  }

  function withdrawManager() external beUsable {
    uint256 inviterIndex = getInvestorIndex(msg.sender);
    uint256 managerAmount = investors[inviterIndex].managerAmount;

    require(managerAmount >= withdrawMinAmount);
    require(address(this).balance >= managerAmount);

    investors[inviterIndex].managerAmount = 0;
    msg.sender.transfer(managerAmount);
    emit Withdraw(msg.sender, 3, managerAmount, now);
  }

  function withdrawAmount() external beUsable {
    uint256 inviterIndex = getInvestorIndex(msg.sender);
    uint256 _applicationTime = investors[inviterIndex].applicationTime;
    uint256 investAmount = investors[inviterIndex].investAmount;
    uint256 investTotalAmount = investors[inviterIndex].investTotalAmount;

    require(now >= applicationTime.add(_applicationTime));
    require(address(this).balance >= investAmount);
    require(investAmount != 0);
    require(investTotalAmount >= withdrawMinInvestAmount);

    investors[inviterIndex].applicationTime = now;
    investors[inviterIndex].investAmount = 0;
    msg.sender.transfer(investAmount);
    emit Withdraw(msg.sender, 4, investAmount, now);
  }

  function getInvestorIndex(address _owner) public view returns (uint256) {
    return inviteCodeToIndex[ownerToInviteCode[_owner]];
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }

  function getInvestorCount() public view returns (uint256) {
    return investors.length;
  }

  function getV1() public view returns (uint256[] memory) {
    return v1;
  }

  function getV2() public view returns (uint256[] memory) {
    return v2;
  }

  function getV3() public view returns (uint256[] memory) {
    return v3;
  }
}