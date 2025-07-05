# AlpyStaking

A minimal ERC20 staking contract written in Solidity. Users can stake a token to earn rewards over time and withdraw both their stake and accumulated rewards.

---

## Overview

This repository contains a simple and gas-efficient staking system using ERC20 tokens. The design follows a linear reward distribution model and tracks user rewards in a scalable way.

Key features:

- Custom ERC20 staking and reward tokens
- Constant reward distribution per second
- Accurate per-user reward tracking
- Partial stake and unstake support
- Fully tested with Foundry

The reward logic uses a `rewardPerTokenStored` model, which ensures scalability even with many users.

---

## How the Contract Works

The contract distributes reward tokens proportionally to each user’s stake over time. It avoids iterating over all users by using a global reward-per-token tracker that updates only during staking, unstaking, or reward withdrawals.

### Functions

- `stakeTokens(uint256 amount)`: Stakes tokens and updates reward tracking for the user.
- `withdrawStakedTokens(uint256 amount)`: Unstakes tokens and updates the user's reward.
- `withdrawEarnedRewards(uint256 amount)`: Transfers earned rewards to the user.
- `userRewards(address user)`: Returns the amount of unclaimed rewards.
- `totalStaked()`: Returns total staked tokens across all users.

---

## Local Testing with Anvil

### 1. Start Anvil locally

```bash
anvil
```

### 2. Deploy to Anvil

```bash
forge script script/DeployStaking.s.sol:DeployStaking \
  --fork-url http://localhost:8545 \
  --broadcast \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

This will deploy:

- The staking token
- The reward token
- The staking contract

Contract addresses will be printed in the logs.

### 3. Interact with the deployed contract

You can use `cast` to call public view functions:

```bash
cast call <staking_contract_address> "totalStaked()(uint256)" \
  --rpc-url http://localhost:8545
```

Replace `<staking_contract_address>` with the deployed address shown in the logs.

---

## Running Tests

Run the Foundry test suite using:

```bash
forge test -vvvv
```

Covers:

- Basic staking and unstaking
- Reward accrual logic
- Edge cases (zero stake, overwithdrawal, no rewards, etc.)
- Multi-user reward fairness

---

## Project Structure

```
AlpyStaking/
├── src/
│   ├── Staking.sol              ← Main staking logic
│   └── test_Staking.sol         ← Full test suite
├── test/
│   └── AlpyStakingTest.sol      ← Basic test with real token
├── lib/
│   └── AlpyToken/               ← ERC20 token implementation
├── script/
│   └── DeployStaking.s.sol      ← Script for local deployment
```

---

## License

MIT
