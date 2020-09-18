// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract staking is ERC20, Ownable {
    using SafeMath for uint256;
    
    address[] internal stakeholders;
    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal rewards;
    
    constructor(address _owner, uint256 _supply) { 
        _mint(_owner, _supply);
    }
    
    function createStake(uint256 _stake) public {
        _burn(msg.sender, _stake);
        if(stakes[msg.sender] == 0) {
            addStakeholder(msg.sender);
        }
        stakes[msg.sender] = stakes[msg.sender].add(_stake);
    }
    
    function removeStake(uint256 _stake) public {
        stakes[msg.sender] = stakes[msg.sender].sub(_stake);
        if(stakes[msg.sender] == 0) {
            removeStakeholder(msg.sender);
        }
        _mint(msg.sender, _stake);
    }
    
    function stakeOf(address _stakeholder) public view returns(uint256) {
        return stakes[_stakeholder];
    }
    
    function totalStakes() public view returns(uint256) {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
        }
        return _totalStakes;
    }
    
    function isStakeholder(address _address) public view returns(bool, uint256) {
        for (uint256 i = 0; i < stakeholders.length; i++){
            if (_address == stakeholders[i]) {
                return (true, i);
            }
        }
        return (false, 0);
    }
    
    function addStakeholder(address _stakeholder) public {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) {
            stakeholders.push(_stakeholder);
        }
    }
    
    function removeStakeholder(address _stakeholder) public {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }
    
    function rewardOf(address _stakeholder) public view returns(uint256) {
        return rewards[_stakeholder];
    }
    
    function totalRewards() public view returns(uint256) {
        uint256 _totalRewards = 0;
        for (uint256 i = 0; i < stakeholders.length; i++){
            _totalRewards = _totalRewards.add(rewards[stakeholders[i]]);
        }
        return _totalRewards;
    }
    
    function calculateReward(address _stakeholder) public view returns(uint256) {
        return stakes[_stakeholder] / 100;
    }
    
    function distributeRewards() public onlyOwner {
        for (uint256 i = 0; i < stakeholders.length; i++){
            address stakeholder = stakeholders[i];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder].add(reward);
        }
    }
    
    function withdrawReward() public {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
    }
}
