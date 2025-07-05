// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "src/Staking.sol";
import "lib/AlpyToken/src/AlpyToken.sol";

contract AlypStakingTest is Test {
    AlypStaking staking;
    AlpyToken stakingToken;
    AlpyToken rewardToken;
    address user;

    function setUp() public {
    user = address(1);
    vm.startPrank(user);

    stakingToken = new AlpyToken(0);
    rewardToken = new AlpyToken(0);

    stakingToken.mint(user, 1e18);
    vm.stopPrank();

    rewardToken.mint(address(this), 1e18);

    staking = new AlypStaking(address(stakingToken), address(rewardToken), 1e16);

    rewardToken.approve(address(staking), 1e18); // ✅ Allow staking contract to use reward tokens
    rewardToken.transfer(address(staking), 1e18); // ✅ Send rewards to staking contract

    vm.startPrank(user);
    stakingToken.approve(address(staking), 1e18);
    vm.stopPrank();
}


    function testStakeAndClaim() public {
    vm.startPrank(user);

    staking.stakeTokens(1e18);
    skip(100); // simulate time

    
    staking.withdrawEarnedRewards(1e16);

    // check that reward was reduced
    uint256 remaining = staking.userRewards(user);
    assertEq(remaining, 1e18 - 1e16, "Remaining rewards should be 0.99 ALPY");


    vm.stopPrank();
}

}
