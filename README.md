# AlpyStaking

A minimalist on-chain staking system where users deposit ERC20 tokens to earn time-based rewards. Built using Solidity, Foundry, and tested thoroughly. Includes mintable token contracts, a dynamic reward model, and clean deployment scripts.

---

## 🔍 How It Works

### 🧱 Core Concepts

- **Stake and Earn:** Users deposit (stake) `stakingToken` to the contract.
- **Reward Per Second:** A fixed emission rate (`rewardRatePerSecond`) defines how many `rewardToken` are distributed per second, proportionally to each user's stake.
- **Time-Based Accounting:** Rewards accumulate over time, and are lazily updated during actions (`stake`, `withdraw`, `claim`).
- **No Lockups:** Users can withdraw their stake or claim rewards at any time.
- **Mintable ERC20s:** Both tokens are simple mock tokens for local testing — fully mintable by anyone.

---

## 🧠 Reward Calculation

Each staker earns rewards based on the formula:

```
rewards = (userStake / totalStaked) * rewardRate * timeElapsed
```

To avoid recomputing for everyone on every block:
- The contract stores `lastUpdate` timestamp.
- Each user has a `userRewards` balance and `userRewardPerTokenPaid` checkpoint.
- When users interact (stake, withdraw, claim), their rewards are updated with minimal gas cost.

---

## 🔐 Security Notes

- This is **not production-hardened**. It’s educational.
- No reentrancy guards, pausability, or role-based access control are implemented.
- Meant to be run in dev environments like Anvil or testnets.

---

## 📦 Project Structure

- `src/AlpyToken.sol` – ERC20 token with mint.
- `src/AlypStaking.sol` – Main staking logic.
- `script/DeployStaking.s.sol` – Deploys staking and tokens.
- `test/AlpyStakingTest.sol` & `test/test_Staking.sol` – Extensive test coverage, edge-case aware.
- `lib/` – Dependencies managed by Foundry (e.g. OpenZeppelin, forge-std).

---

## 🚀 Usage

### 1. Install Dependencies

```bash
forge install
```

### 2. Compile Contracts

```bash
forge build
```

### 3. Run All Tests

```bash
forge test -vvv
```

---

## 🧪 Anvil Testing Walkthrough

### Step 1: Start a Local Node

```bash
anvil
```

Keep note of the first private key and address it prints. You'll use these below.

### Step 2: Deploy Contracts

```bash
forge script script/DeployStaking.s.sol:DeployStaking \
  --fork-url http://localhost:8545 \
  --broadcast \
  --private-key <PRIVATE_KEY>
```

You’ll see logs with deployed contract addresses.

### Step 3: Interact Manually

#### ✅ Check Total Staked

```bash
cast call <staking_contract_address> "totalStaked()(uint256)" \
  --rpc-url http://localhost:8545
```

#### 💸 Mint Tokens

```bash
cast send <staking_token_address> "mint(address,uint256)" <your_address> 1000000000000000000 \
  --private-key <PRIVATE_KEY> --rpc-url http://localhost:8545
```

#### 🧾 Approve the Staking Contract

```bash
cast send <staking_token_address> "approve(address,uint256)" <staking_contract_address> 1000000000000000000 \
  --private-key <PRIVATE_KEY> --rpc-url http://localhost:8545
```

#### 📥 Stake Tokens

```bash
cast send <staking_contract_address> "stakeTokens(uint256)" 1000000000000000000 \
  --private-key <PRIVATE_KEY> --rpc-url http://localhost:8545
```

#### ⏱ Warp Time (Simulate Time Passing)

```bash
cast rpc evm_increaseTime 100
cast rpc evm_mine
```

#### 🎁 Claim Rewards

```bash
cast send <staking_contract_address> "withdrawEarnedRewards(uint256)" 10000000000000000 \
  --private-key <PRIVATE_KEY> --rpc-url http://localhost:8545
```

#### 📊 Check User Rewards

```bash
cast call <staking_contract_address> "userRewards(address)(uint256)" <your_address> \
  --rpc-url http://localhost:8545
```

---

## 🧪 Example Test Scenarios

- Stake 100 tokens, simulate 10 seconds, claim 10 rewards.
- Stake by two users with time offsets to verify proportional accrual.
- Attempt invalid withdrawals (e.g. zero stake, overclaim).
- Time-based reward edge cases validated with Foundry's `warp`.

---

## 🧾 License

MIT
