# 🦄 SimpleSwap

A minimalistic Automated Market Maker (AMM) smart contract, inspired by Uniswap V2. 
This contract allows users to **add/remove liquidity**, **swap between two ERC20 tokens**, and **query prices**, with **no fees**.

---

## ✨ Features

- Add and remove liquidity from a token pool
- Swap exact tokens between tokenA and tokenB
- No protocol fees
- Price querying functionality
- Liquidity proportional minting and burning
- Safe deadline and slippage parameters

---

## 📦 Contract Details

- **Name**: `SimpleSwap`
- **Solidity Version**: `^0.8.0`
- **Dependencies**: None (includes custom `IERC20` interface)

---

## 🔧 Deployment

### 1. Prerequisites

- Solidity 0.8.x
- Remix, Hardhat, or Foundry
- Two ERC20 tokens deployed

### 2. Constructor

```solidity
constructor(address _tokenA, address _tokenB)
_tokenA: address of token A
_tokenB: address of token B

🚀 Usage
🧪 Add Liquidity
addLiquidity(
  uint amountADesired,
  uint amountBDesired,
  uint amountAMin,
  uint amountBMin,
  address to,
  uint deadline
)
Approve amountADesired and amountBDesired to the contract first.
deadline = block.timestamp + seconds (e.g. block.timestamp + 3600 for 1 hour)
💸 Remove Liquidity
removeLiquidity(
  uint liquidity,
  uint amountAMin,
  uint amountBMin,
  address to,
  uint deadline
)
🔄 Swap Tokens
swapExactTokensForTokens(
  uint amountIn,
  uint amountOutMin,
  address[] path, // [inputToken, outputToken]
  address to,
  uint deadline
)
📈 Get Price
getPrice(address tokenA, address tokenB) returns (uint price)

⚠️ Notes
This AMM is fee-less. Slippage can be significant.
Only supports a single pair: tokenA & tokenB.
Does not include Ownable, ReentrancyGuard, or price oracles.

📄 License
MIT © 2025

🧠 Credits
Inspired by Uniswap v2 mechanics and implemented for learning, testing, and experimentation.
