# 🦄 SimpleSwap Project 

This project includes a fully functional decentralized application (dApp) that enables users to interact seamlessly with blockchain-based smart contracts through a clean and responsive frontend. This dApp includes token swaps, minting tokens and pricing information using a custom-built automated market maker (AMM) protocol through SimpleSwap contract.  

## 📁 Project Structure  
/contracts  
│  
├── SimpleSwap.sol # SimpleSwap contract  
├── TokenA.sol     # TokenA contract  
├── TokenB.sol     # TokenB contract  
│  
/frontend  
│  
├── index.html     # Main interface  
├── styles.css     # Swap UI styles  
├── scripts.js     # Web3 logic and contract interaction  
│  
/test  
│  
├── SimpleSwapTest.js     # Testing script  

---

## ⚙️ SimpleSwap Smart Contract  

### 📄 Description  

This smart contract acts as a lightweight decentralized exchange (DEX), inspired by Uniswap’s core design. It enables token swaps, liquidity management, and pricing based on reserve ratios.  

### 📚 Overview  

**SimpleSwap** is a decentralized exchange (DEX) smart contract implemented in Solidity. It allows users to:  

1. Add liquidity to a pool of two ERC-20 tokens.  
2. Remove liquidity from an existing pool.  
3. Swap tokens between pairs with an automatic pricing mechanism.  
4. Query token prices.  
5. Query expected swap outputs.  

### 🧠 Core Concepts  

1. **Features**  
   - Constant Product AMM (`x * y = k`) mechanism  
   - ERC-20 compliant interface for token interactions  
   - Slippage protection and transaction deadlines  

2. **Liquidity Pools**:  
   - Each token pair (`tokenA`, `tokenB`) is associated with a `LiquidityData` structure.  
   - This structure contains:  
     - `totalLiquidity`: Total amount of liquidity tokens issued.  
     - `liquidityBalance`: Mapping of user addresses to their liquidity balance.  
     - `reserves`: Current token reserves (`reserveA` and `reserveB`).  

3. **Events**:  
   - `LiquidityAdded`: Emitted when a user provides liquidity to a pool.  
   - `LiquidityRemoved`: Emitted when a user withdraws liquidity.  
   - `TokensSwapped`: Emitted when a swap is successfully executed.    

4. **Modifiers & Safety Checks**:  
   - validTokenPair — ensures input tokens match the pair  
   - notExpired — enforces deadlines for time-sensitive txs  
   - validRecipient — ensures to address is not zero  

### 🔧 Public Functions, Parameters & Returns  

#### 1. 💧 Add Liquidity  
- Function: `addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, deadline)`  
- Functionality:  
                - Provides liquidity to a token pair.  
                - Calculates optimal token proportions and ensures slippage protection.  
                - Mints and assigns liquidity tokens to the `to` address.  
- Parameters:  
             - addTokenA (Must match deployed tokenA address)  
             - addTokenB (Must match deployed tokenB address)  
             - amountADesired (Desired amount of tokenA to deposit)  
             - amountBDesired (Desired amount of tokenB to deposit)  
             - amountAMin (Minimum amount of tokenA to accept (slippage protection))  
             - amountBMin (Minimum amount of tokenB to accept (slippage protection))  
             - to (Recipient of LP (liquidity provider) tokens)  
             - deadline (Expiry timestamp for the transaction)  
- Returns:   
          - amountA (Actual amount of tokenA added to the pool)  
          - amountB (Actual amount of tokenB added to the pool)  
          - liquidity (Amount of liquidity (LP) tokens minted for the provider)  

#### 2. 🔓 Remove Liquidity  
- Function: `removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline)`  
- Functionality:  
                - Withdraws user's share of the liquidity pool.  
                - Burns liquidity tokens and returns `tokenA` and `tokenB`.  
                - Enforces slippage and deadline constraints.  
- Parameters:  
             - addTokenA (Must match deployed tokenA address)  
             - addTokenB (Must match deployed tokenB address)  
             - liquidity (Amount of LP tokens to burn)  
             - amountAMin (Minimum amount of tokenA to receive (slippage protection))  
             - amountBMin (Minimum amount of tokenB to receive (slippage protection))  
             - to (Address receiving the withdrawn tokens)  
             - deadline (Expiry timestamp for this transaction)  
- Returns:  
          - amountA (Amount of tokenA returned to the user)  
          - amountB (Amount of tokenB returned to the user)  

#### 3. 🔁 Swap Tokens  
- Function: `swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline)`  
- Functionality:  
                - Swaps a fixed amount of input tokens.  
                - Supports a single-pair path `[tokenA, tokenB]`.  
                - Uses constant product formula.  
                - Transfers output tokens to the recipient.  
- Parameters:  
             - amountIn (Exact amount of input token to swap)  
             - amountOutMin (Minimum acceptable output amount (slippage protection))  
             - path (Array: [inputToken, outputToken] (length must be 2))  
             - to (Address to receive output tokens)  
             - deadline (Unix timestamp after which the transaction is invalid)  
- Returns:  
          - amounts[0] (Actual amount of input token spent)  
          - amounts[1] (Actual amount of output token received)

#### 4. 📊 Get Price  
- Function: `getPrice(tokenA, tokenB)`  
- Functionality:  
                - Returns the current price of `tokenA` denominated in `tokenB`.
                - Price is scaled by `1e18`.
- Parameters:  
             - tokenA (Must match deployed tokenA address)  
             - tokenB (Must match deployed tokenB address)  
- Returns: price (The price of 1 tokenA in terms of tokenB, scaled by 1e18)  

#### 5. 📈 Calculate Swap Output  
- Function:`getAmountOut(amountIn, reserveIn, reserveOut)`  
- Functionality:  
                - Calculates the output amount for a given input, using the constant product formula.  
                - Validates that reserves and input are non-zero.  
- Parameters:  
             - amountIn (Amount of input token)  
             - amountA (Reserve of input token)  
             - amountB (Reserve of output token)  
- Returns: amountOut (Estimated amount of output tokens given input amount and reserves)  

### 📍 Deployed Contracts (Network: Ethereum / Sepolia)  
 - TokenA Contract Address: [0x8d3Fa8a2b8F5e41AAb5574EaaFB78Dd5B8F1B9D7]  
 - TokenB Contract Address: [0x3A646b73630B24fc2E038DD6AE57eF666f3F8762]  
 - SimpleSwap Contract Address: [0x411367061FE56Aba34F8c6bBb6b24Bd4496B9FF0]  

### ⚠️ Notes  
 - Only supports one token pair per deployment  
 - No fee or incentive mechanism for liquidity providers  
 - LP tokens are tracked via internal mappings (not ERC-20 tokens)  

### 🛠️ Requirements  
 - Solidity ^0.8.0  
 - Two valid ERC-20 tokens  
 - Approval must be granted to the contract before token transfers  

### 🔐 Access Control  
 - There are no owner-only functions. Anyone can:  
      - Add/remove liquidity  
      - Swap tokens  
      - Query pricing  

---

## 🧩 SimpleSwap Decentralized Application (dApp)  

### 📄 Description  

**SimpleSwap dApp** is a simple web application to interact with an ERC-20 token swap contract deployed on Sepolia blockchain (Ethereum testnet) by connecting to the SimpleSwap smart contract.  

### ✨ Features  

- 🔄 **Token Swap Interface** – Swap between supported tokens with real-time pricing.  
- 👛 **Wallet Integration** – Connect MetaMask wallets (sepolia).  
- 🪙 **Token Minting** – Mint both tokens directly from the interface with one click (great for testing).  
- 💰 **Balance Display** – View live balances of two custom tokens (TokenA and TokenB).  
- 🔐 **Secure Interactions** – All transactions occur on-chain (testnet) via verified smart contracts.  
- ⚡ **Fast & Responsive UI** – Clean CSS-powered interface with no heavy frameworks.  
- 🔔 **Feedback System** – Alert notifications and loading spinners for improved UX.  

### 🖼️ UI Overview  
The user interface includes:  
  - **Connect Button** – Connects wallet functionality  
  - **Mint Token A/B Boxes** – UI for entering amounts of tokens to mint  
  - **Mint Token A/B Buttons** – Mints tokens to your wallet  
  - **Swap Boxes** – Main UI for entering amounts of Token A and see previews of Token B before swappimg.  
  - **Swap/Approve Button** – Executes the transaction with a single click (swap or approve).  
  - **Real-Time Info** – Displays token balances and swap prices.  

### 🔧 Prerequisites  

MetaMask installed and connected to the correct network (sepolia ethereum testnet)  

### 🔗 dApp Link  

[https://monandbri.github.io/Modulo4_ETH_Kipu_SimpleSwap/]  

### 🚀 How to Use  
✅ Ensure MetaMask is installed and connected to sepolia  

#### 1. In your browser, paste dApp Link  
<img width="1913" height="955" alt="image" src="https://github.com/user-attachments/assets/8b0b95db-8dfe-4f4b-b17d-17e6d08c1c49" />  

#### 2. Click the Connect button to link your MetaMask account  

#### 3. Once connected, you can:  
- Mint test tokens (TokenA (TKA) & TokenB (TKB)) to your wallet  
- Enter an amount of Token A or Token B, then click Mint  
- Enter the amount of Token A (to be swapped for Token B)  
- Get a quote for how many Token B you will receive  
- Approve token usage  
- Execute the token swap  
- Watch for success or error notifications via alert messages.  

### 🛠 Built With  

- **HTML5 / CSS3** – Lightweight and responsive design.  
- **JavaScript** – Core logic for frontend interactivity.  
- **Ethers.js** – Blockchain communication.  
- **MetaMask** – Wallet connection and transaction signing.  
- **Contracts / ABIs** – Smart contracts addresses and ABIs are embedded directly in the JavaScript code – no external deployment files required.  


---

## 🧪 SimpleSwap Contract Test Suite  

### 📄 Description  

This test suite validates all functionality of the SimpleSwap, TokenA and TokenB smart contracts.  

### 📚 Overview  

**Test file** covers:  
- Deployment and initialization  
- Token minting and approvals  
- Liquidity provision and withdrawal  
- Swapping tokens  
- Price and reserve calculations  
- Slippage and deadline protection  
- Proper event emissions  

### 📦 Project Structure  

- `TokenA.sol` / `TokenB.sol`: Custom ERC20 tokens with no decimals, used for testing swaps and liquidity provisioning.  
- `SimpleSwap.sol`: Core smart contract implementing the liquidity pool logic, swaps, and slippage protection.  
- `SimpleSwap.test.js`: This file — a complete test suite for all major contract functionalities.  

### 🛠 Tools & Stack  

- **Hardhat** – Ethereum development environment.  
- **Chai** – Assertion library.  
- **Ethers.js** – For interacting with contracts and the provider.  
- **Mocha** – Test runner.  

### ✅ Key Test Coverage  

#### 🔹 Initial State Checks  
- `totalLiquidity`, `reserveA`, and `reserveB` return `0` before any liquidity is added.  

#### 🔹 Minting  
- `mint()` function works properly on custom tokens.  

#### 🔹 Liquidity Provisioning  
- `addLiquidity()`:  
  - ✅ Correct liquidity token calculation via `sqrtSolidityStyle()`  
  - ✅ Handles slippage (`amountAMin`, `amountBMin`) and deadline  
  - ✅ Emits `LiquidityAdded` with correct values  

#### 🔹 Optimal Amount Calculation  
- Fallback paths (`amountAOptimal`, `amountBOptimal`) in `_calculateOptimalAmounts()` are tested.  

#### 🔹 Slippage Protection  
- Tests revert scenarios where:  
  - ❌ `amountA < amountAMin`  
  - ❌ `amountB < amountBMin`  
  - ❌ Liquidity minted is zero  

#### 🔹 Swapping  
- `swapExactTokensForTokens()`:  
  - ✅ Emits `TokensSwapped`  
  - ✅ Validates `amountOutMin`, `path`, and reserves  
  - ✅ Handles cases with insufficient liquidity or output  

#### 🔹 Removing Liquidity  
- `removeLiquidity()`:  
  - ✅ Updates balances and reserves correctly  
  - ✅ Emits `LiquidityRemoved`  
  - ✅ Handles edge cases:  
    - Zero liquidity  
    - Exceeding user’s liquidity balance  
    - Insufficient token output  

#### 🔹 Price & Output Calculation  
- `getPrice(tokenA, tokenB)`:  
  - ✅ Returns correct spot price (scaled by `1e18`)  
  - ❌ Reverts if no liquidity  

- `getAmountOut()`:  
  - ✅ Correctly calculates output from `amountIn`, `reserveIn`, `reserveOut`  
  - ❌ Reverts if invalid input values are passed  

### ✅ What is tested?  

#### ✅ Deployment & Setup  

- Deployment of `TokenA`, `TokenB`, and `SimpleSwap`.  
- Minting and approving tokens.  
- Setting up initial liquidity.  

#### ✅ Liquidity Functions  

- `addLiquidity()`:  
  - Adds token pairs into the pool.  
  - Calculates optimal amounts.  
  - Handles slippage protection (`amountAMin`, `amountBMin`).  
  - Emits `LiquidityAdded` event.  
- `removeLiquidity()`:  
  - Withdraws tokens based on user's LP shares.  
  - Validates minimum output and liquidity balance.  
  - Emits `LiquidityRemoved` event.  

#### ✅ Pricing & Reserves  

- `getPrice(tokenA, tokenB)`:  
  - Returns the exchange rate (price) using current reserves.  
  - Reverts when `reserveA` is zero.  
- `getAmountOut(amountIn, tokenIn, tokenOut)`:  
  - Calculates the output amount for swaps.  
  - Validates against zero input or zero reserves.  

#### ✅ Swap Function  

- `swapExactTokensForTokens(...)`:  
  - Swaps tokens using path `[tokenA, tokenB]` or `[tokenB, tokenA]`.  
  - Reverts on:  
    - Zero input  
    - Insufficient liquidity  
    - Invalid token path  
    - Slippage (`amountOut < amountOutMin`)  
    - Invalid pair  
  - Emits `TokensSwapped` event.  

### 🧪 Example Tests  

- ✅ Check that initial liquidity is `0`.  
- ✅ Validate that the correct amounts are stored in reserves.  
- ✅ Ensure optimal token ratios are calculated during `addLiquidity()`.  
- ✅ Validate `LiquidityAdded` and `TokensSwapped` events.  
- ✅ Test slippage protection and deadline handling.  
- ✅ Confirm that reverts occur when:  
  - Liquidity is insufficient  
  - Swap input is zero  
  - User tries to remove more liquidity than they own  

### 🚀 Running the Tests & Checking Coverage  

  - npx hardhat test  
<img width="997" height="896" alt="image" src="https://github.com/user-attachments/assets/0ff06856-a625-4988-9da3-5d9497fc5ad4" />  

  - npx hardhat coverage  
<img width="883" height="361" alt="image" src="https://github.com/user-attachments/assets/7996056f-c716-412d-9d78-4767f3c180f3" />  

### 📌 Notes  

  - No token decimals: Both TokenA and TokenB use 0 decimals to simplify calculations and assertions.  
  - Custom LP logic: LP tokens and pricing are calculated using √(amountA * amountB), not Uniswap V2’s full formula.  

### 📄 License  
MIT – Use and modify freely.  
This project is open-source and intended for educational and testing purposes.  
Not recommended for production/mainnet usage without audits.  

### 🙌 Credits  
Created by Mónica Andrea Brito as part of ETH KIPU Developer Ethereum & Talento Tech learning education project.  
Thanks for visiting!  
