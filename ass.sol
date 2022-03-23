// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
// import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract StakingToken is ERC20, Ownable {
    uint256 lastCollect;
    constructor() ERC20("Serty Token", "SET") {
      _mint(msg.sender, 1000);
      lastCollect=block.timestamp-7 days;
    }

    // using SafeMath for uint256;
    address[] internal stakeholders;
    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal rewards;

    function buyToken(address reciever) public payable returns (uint256) {
      require(msg.value > 0, "Send ETH to buy some tokens");

      uint256 amountToBuy = msg.value*10**18 * 1000;

      _mint(reciever, amountToBuy);
      return amountToBuy;
    }

    function createStake(uint256 _stake)
        public
    {
        _burn(msg.sender, _stake);
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stakes[msg.sender] = stakes[msg.sender]+=_stake;
    }

    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }
    
    function addStakeholder(address _stakeholder)
        public
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }

    function calculateReward(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stakes[_stakeholder] / 100;
    }
    
    function distributeRewards() 
        public
        onlyOwner
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            address stakeholder = stakeholders[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder]+=reward;
        }
    }

    function totalStakes()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes+=stakes[stakeholders[s]];
        }
        return _totalStakes;
    }
    
    function modifyTokenBuyPrice() public onlyOwner {}
    
    function withdrawReward() 
        public
    {
          require(lastCollect + 7 days < block.timestamp, "Tokens can be claimed after 7 days" );
          uint256 reward = rewards[msg.sender];
          rewards[msg.sender] = 0;
          lastCollect = block.timestamp;
          _mint(msg.sender, reward);
    }
}
