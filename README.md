# AlpyStaking

A minimal ERC20 staking contract written in Solidity. Users can stake a token to earn rewards over time, and withdraw both their stake and accumulated rewards.

---

## 📄 Overview

This repo contains a gas-efficient, time-based staking system written in Solidity 0.8.19+. It supports:

- **Custom ERC20 staking/reward tokens**
- **Linear reward distribution per second**
- **Partial or full staking/unstaking**
- **Accurate per-user reward tracking**
- **Onchain tests with Foundry**

The reward logic is implemented using a global `rewardPerTokenStored` mechanism for scalability, without storing per-second history.

---

## 🔍 Contract Explanation

### Core Components

- `stakeTokens(uint256 amount)`: Stakes the given amount of tokens. Updates user reward accounting.
- `withdrawStakedTokens(uint256 amount)`: Unstakes the given amount. Also updates rewards.
- `withdrawEarnedRewards(uint256 amount)`: Transfers accumulated reward tokens to user.
- `userRewards(address user)`: Returns claimable rewards for a user.
- `totalStaked()`: Returns the total amount of staked tokens in the contract.

### Reward Mechanism

- The contract distributes rewards at a constant `rewardRate` per second.
- When any action occurs (stake/unstake/claim), it updates the user's pending rewards based on elapsed time.
- This avoids reward dilution and prevents users from gaming the system.

---

## 🔨 Usage (Local Anvil Setup)

To deploy and test this contract locally with Anvil:

### 1. Start Anvil
```bash
anvil
```

### 2. Deploy the Contract
```bash
forge script script/DeployStaking.s.sol:DeployStaking \
  --fork-url http://localhost:8545 \
  --broadcast \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

### 3. Check Deployed Contract
Replace the address with the one emitted during deployment:
```bash
cast call <staking_contract_address> "totalStaked()(uint256)" \
  --rpc-url http://localhost:8545
```

---

## ✅ Run Tests

Tests are written in Foundry. Includes both basic and edge cases:

```bash
forge test -vvvv
```

Includes:

- Staking/unstaking
- Reward accrual over time
- Zero/invalid amounts
- Multiple users interacting concurrently

---

## 🗂️ Structure

```
AlpyStaking/
├── src/
│   ├── Staking.sol
│   └── test_Staking.sol
├── lib/
│   └── AlpyToken (ERC20)
├── script/
│   └── DeployStaking.s.sol
└── test/
    └── AlpyStakingTest.sol
```

---

## 📜 License

This project is licensed under the MIT License.
