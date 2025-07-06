// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/forge-std/src/Test.sol";
import "../src/Staking.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";




// Minimal ERC20 mock for testing
contract ERC20Mock is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public override totalSupply;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        require(balanceOf[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(balanceOf[from] >= amount, "ERC20: transfer amount exceeds balance");
        require(allowance[from][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
}
}

contract StakingTest is Test {
    ERC20Mock stakingToken;
    ERC20Mock rewardToken;
    AlypStaking staking;
    address user = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        stakingToken = new ERC20Mock("Stake", "STK");
        rewardToken = new ERC20Mock("Reward", "RWD");
        staking = new AlypStaking(address(stakingToken), address(rewardToken), 1e18); // 1 token/sec

        stakingToken.mint(user, 1000 ether);
        rewardToken.mint(address(staking), 1000 ether);

        vm.prank(user);
        stakingToken.approve(address(staking), type(uint256).max);
    }

    function testStakeTokensIncreasesBalances() public {
        vm.prank(user);
        staking.stakeTokens(100 ether);
        assertEq(staking.userStakes(user), 100 ether);
        assertEq(staking.totalStaked(), 100 ether);
        assertEq(stakingToken.balanceOf(address(staking)), 100 ether);
        assertEq(stakingToken.balanceOf(user), 900 ether);
    }

    function testCannotStakeZero() public {
        vm.prank(user);
        vm.expectRevert(bytes("Cannot stake 0"));
        staking.stakeTokens(0);
    }

    function testWithdrawStakedTokens() public {
        vm.startPrank(user);
        staking.stakeTokens(100 ether);
        staking.withdrawStakedTokens(40 ether);
        assertEq(staking.userStakes(user), 60 ether);
        assertEq(staking.totalStaked(), 60 ether);
        assertEq(stakingToken.balanceOf(user), 940 ether);
        vm.stopPrank();
    }

    function testCannotWithdrawZero() public {
        vm.prank(user);
        staking.stakeTokens(100 ether);
        vm.prank(user);
        vm.expectRevert(bytes("Cannot withdraw 0"));
        staking.withdrawStakedTokens(0);
    }

    function testCannotWithdrawMoreThanStaked() public {
        vm.prank(user);
        staking.stakeTokens(100 ether);
        vm.prank(user);
        vm.expectRevert(bytes("amount exceeds staked balance"));
        staking.withdrawStakedTokens(200 ether);
    }

    function testRewardsAccrueOverTime() public {
        vm.prank(user);
        staking.stakeTokens(100 ether);

        vm.warp(block.timestamp + 10);

        vm.prank(user);
        staking.withdrawEarnedRewards(10 ether);
        assertEq(rewardToken.balanceOf(user), 10 ether);
        assertEq(staking.userRewards(user), 0);
    }

    function testCannotWithdrawMoreRewardsThanEarned() public {
        vm.prank(user);
        staking.stakeTokens(100 ether);
        vm.warp(block.timestamp + 5);
        vm.prank(user);
        vm.expectRevert(bytes("Not enough rewards"));
        staking.withdrawEarnedRewards(10 ether);
    }

    function testCannotWithdrawRewardsIfNone() public {
        vm.prank(user);
        vm.expectRevert(bytes("No rewards to claim"));
        staking.withdrawEarnedRewards(1 ether);
    }

    }

