# 🌀 SimpleSwap

## 💡 Overview
A minimal Uniswap-like Automated Market Maker (AMM) smart contract for a single pair of ERC-20 tokens. This contract allows users to:

- Add and remove liquidity
- Swap between two tokens
- Query pool prices and output estimates

> ⚠️ No fees are collected in this AMM, and it supports only one token pair per deployment.

---

## 📍 Deployed Contract

**Network:** Ethereum / Sepolia 

 **Contract Address:** [0xF61e6cC61C7Ca23ee17F2e1f00d3BDD5C519cf39] https://sepolia.etherscan.io/address/0xF61e6cC61C7Ca23ee17F2e1f00d3BDD5C519cf39

---

## 📦 Features

- Constant Product AMM (`x * y = k`) mechanism
- ERC-20 compliant interface for token interactions
- Slippage protection and transaction deadlines
- Fully gas-optimized internal math and reserve management

---

## 🚀 Getting Started

### Deployment

Deploy the `SimpleSwap` contract with two ERC-20 token addresses:
  TokenA: 0xFA1e34EdDcd8cbF6983b08A5EF3Fd251251d92d3
  TokenB: 0x6749ff788dC350AbBc09B54651a457535F04715c

```solidity
constructor(address _tokenA, address _tokenB)
Parameter	Description
_tokenA	Address of first ERC-20 token
_tokenB	Address of second ERC-20 token (must differ from _tokenA)

⚙️ Public Functions & Parameters
1. 🔁 Swap Tokens

function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
) external returns (uint256[] memory amounts)
Inputs
Parameter	Description
amountIn	Exact amount of input token to swap
amountOutMin	Minimum acceptable output amount (slippage protection)
path	Array: [inputToken, outputToken] (length must be 2)
to	Address to receive output tokens
deadline	Unix timestamp after which the transaction is invalid

Returns
Variable	Description
amounts[0]	Actual amount of input token spent
amounts[1]	Actual amount of output token received

2. 💧 Add Liquidity

function addLiquidity(
    address addTokenA,
    address addTokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
) external returns (uint256 amountA, uint256 amountB, uint256 liquidity)
Inputs
Parameter	Description
addTokenA	Must match deployed tokenA address
addTokenB	Must match deployed tokenB address
amountADesired	Desired amount of tokenA to deposit
amountBDesired	Desired amount of tokenB to deposit
amountAMin	Minimum amount of tokenA to accept (slippage protection)
amountBMin	Minimum amount of tokenB to accept (slippage protection)
to	Recipient of LP (liquidity provider) tokens
deadline	Expiry timestamp for the transaction

Returns
Variable	Description
amountA	Actual amount of tokenA added to the pool
amountB	Actual amount of tokenB added to the pool
liquidity	Amount of liquidity (LP) tokens minted for the provider

3. 🔓 Remove Liquidity

function removeLiquidity(
    address addTokenA,
    address addTokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
) external returns (uint256 amountA, uint256 amountB)
Inputs
Parameter	Description
addTokenA	Must match deployed tokenA address
addTokenB	Must match deployed tokenB address
liquidity	Amount of LP tokens to burn
amountAMin	Minimum amount of tokenA to receive (slippage protection)
amountBMin	Minimum amount of tokenB to receive (slippage protection)
to	Address receiving the withdrawn tokens
deadline	Expiry timestamp for this transaction

Returns
Variable	Description
amountA	Amount of tokenA returned to the user
amountB	Amount of tokenB returned to the user

4. 📊 Get Price

function getPrice(address _tokenA, address _tokenB) external view returns (uint256 price)
Inputs
Parameter	Description
_tokenA	Must match deployed tokenA address
_tokenB	Must match deployed tokenB address

Returns
Variable	Description
price	The price of 1 tokenA in terms of tokenB, scaled by 1e18

5. 📈 Calculate Swap Output

function getAmountOut(
    uint256 amountIn,
    uint256 amountA,
    uint256 amountB
) public pure returns (uint256 amountOut)
Inputs
Parameter	Description
amountIn	Amount of input token
amountA	Reserve of input token
amountB	Reserve of output token

Returns
Variable	Description
amountOut	Estimated amount of output tokens given input amount and reserves

🧯 Modifiers & Safety Checks
validTokenPair — ensures input tokens match the pair

notExpired — enforces deadlines for time-sensitive txs

validRecipient — ensures to address is not zero

📜 Events
LiquidityAdded

LiquidityRemoved

TokensSwapped

These allow for off-chain monitoring and analytics.

⚠️ Notes
Only supports one token pair per deployment

No fee or incentive mechanism for liquidity providers

LP tokens are tracked via internal mappings (not ERC-20 tokens)

📊 Pricing and Estimates
Get Current Price (scaled by 1e18)
uint256 price = swap.getPrice(tokenA, tokenB);

Estimate Output Amount
uint256 out = swap.getAmountOut(amountIn, reserveIn, reserveOut);

🛠️ Requirements
Solidity ^0.8.0

Two valid ERC-20 tokens

Approval must be granted to the contract before token transfers

🔐 Access Control
There are no owner-only functions. Anyone can:

Add/remove liquidity

Swap tokens

Query pricing

📄 License
This project is licensed under the MIT License.
See the LICENSE file for details.

👨‍💻 Author
Mónica Andrea Brito

🧪 Testing Tips
Use ERC-20 mocks for local tests (e.g., via Hardhat).

Simulate slippage by manipulating reserve ratios.

Verify all deadline-based calls with block.timestamp.

🧠 Further Improvements (Suggestions)
Support trading fees (e.g., 0.3%)

Add LP token minting as a proper ERC-20

Enable multi-hop swaps and router integration

Front-end DApp interface for UX

✅ Example Workflow
Deploy SimpleSwap with two token addresses

Approve the contract to transfer tokens on your behalf

Call addLiquidity(...)

Perform swaps with swapExactTokensForTokens(...)

Remove your share via removeLiquidity(...)
