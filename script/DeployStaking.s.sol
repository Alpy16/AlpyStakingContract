// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Staking.sol";
import "../lib/AlpyToken/src/AlpyToken.sol";

contract DeployStaking is Script {
    function setUp() public {}

    function run() external {
        vm.startBroadcast();

        AlpyToken stakingToken = new AlpyToken(1_000_000 ether);
        AlpyToken rewardToken = new AlpyToken(1_000_000 ether);

        AlypStaking staking = new AlypStaking(
            address(stakingToken),
            address(rewardToken),
            1e18 // 1 token/sec reward rate
        );

        rewardToken.transfer(address(staking), 500_000 ether);

        console.log("StakingToken deployed to: %s", address(stakingToken));
        console.log("RewardToken deployed to: %s", address(rewardToken));
        console.log("Staking contract deployed to: %s", address(staking));

        vm.stopBroadcast();
    }
}
