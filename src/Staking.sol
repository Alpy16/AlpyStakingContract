//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AlpyToken} from "lib/AlpyToken/src/AlpyToken.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
contract AlypStaking {
// 1. Calculate how much time has passed since last update
// 2. If totalStaked > 0, calculate how much reward was generated during that time
// 3. Add reward per token to global variable
// 4. Update lastUpdateTime
// 5. For the specific user:
//    - calculate how much they earned since their last checkpoint
//    - add that to their pending rewards
//    - update their reward debt


IERC20 public stakingToken;
IERC20 public rewardToken;
uint256 public rewardRate;
uint256 public lastUpdateTime;
uint256 public rewardPerTokenStored;
uint256 public totalStaked;
mapping(address => uint256) public userStakes;
mapping(address => uint256) public userRewards;
mapping(address => uint256) public userRewardDebt;

event UserClaimedRewards(address indexed user, uint256 amount);






    constructor(address _stakingToken, address _rewardToken, uint256 _rewardRate) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
        lastUpdateTime = block.timestamp;
        rewardPerTokenStored = 0;
        

     
    }

    function _updateRewards(address user) internal {
    // 1. Time since last reward update
    uint256 timeElapsed = block.timestamp - lastUpdateTime;

    // 2. If time passed, calculate and add to accRewardPerToken
    if (timeElapsed > 0) {
        uint256 reward = timeElapsed * rewardRate;

        if (totalStaked > 0) {
            rewardPerTokenStored += (reward * 1e18) / totalStaked;
        }

        lastUpdateTime = block.timestamp;
    }

    // 3. If a specific user is involved, update their rewards
    if (user != address(0)) {
    // Calculate how much reward this user earned since their last update
    uint256 delta;
    if (rewardPerTokenStored >= userRewardDebt[user]) {
        delta = rewardPerTokenStored - userRewardDebt[user];
    } else {
        delta = 0;
    }

    // Apply their share of the new rewards based on how much they staked
    uint256 userEarned = (userStakes[user] * delta) / 1e18;

    // Add newly earned rewards to their total unclaimed rewards
    userRewards[user] += userEarned;

    // Reset their reward debt to current baseline (prevents double counting)
    userRewardDebt[user] = (userStakes[user] * rewardPerTokenStored) / 1e18;
}

    
}

    function stakeTokens(uint256 amount) external {
        require(amount > 0, "Cannot stake 0"); // doesnt make any sense to deposit 0
        _updateRewards(msg.sender); //calls the updateRewards fucntion to update the entire set of info we are gonna use 
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed"); //checks if the tokens actually got transferred and reverts with an error if the transfer fails
        userStakes[msg.sender] += amount; //updates the total staked amount by the specific user who call the function (msg.sender)
        totalStaked += amount; //this updates the total stake pool across all of the users
        userRewardDebt[msg.sender] = userStakes[msg.sender] * rewardPerTokenStored / 1e18  ; //calculates total rewards earned and lets us use it as a checkpoint in order to only account for rewards earned after this point
        
        
}

    function withdrawStakedTokens (uint256 amount) external {
        _updateRewards(msg.sender);
        require(amount > 0, "Cannot withdraw 0");
        require(amount <= userStakes[msg.sender],"amount exceeds staked balance");
        
        stakingToken.transfer(msg.sender, amount);
        userStakes[msg.sender] -= amount;
        totalStaked -= amount; 
        userRewardDebt[msg.sender] = (userStakes[msg.sender] * rewardPerTokenStored) / 1e18;
        //almost all of the logic is inherited
}
    
    function withdrawEarnedRewards (uint256 amount) public {
        _updateRewards(msg.sender);
        require(userRewards[msg.sender] > 0, "No rewards to claim");
        require(amount <= userRewards[msg.sender], "Not enough rewards");
         
        userRewards[msg.sender] -= amount;
        rewardToken.transfer(msg.sender, amount);

        emit UserClaimedRewards(msg.sender, amount);
        }







    
 



        

    
        
    
}