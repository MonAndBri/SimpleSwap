// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ERC-20 Interface
/// @notice Interface for interacting with ERC-20 tokens
interface IERC20 {
    /// @notice Returns the total number of tokens in existence
    function totalSupply() external view returns (uint256);

    /// @notice Returns the number of tokens owned by `account`
    function balanceOf(address account) external view returns (uint256);

    /// @notice Transfers `amount` tokens to `recipient`
    /// @param recipient The address to transfer tokens to
    /// @param amount The amount of tokens to transfer
    function transfer(address recipient, uint256 amount) external returns (bool);

    /// @notice Returns the remaining number of tokens that `spender` can spend on behalf of `owner`
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Sets `amount` as the allowance of `spender` over the caller’s tokens
    /// @param spender The address that will spend the tokens
    /// @param amount The number of tokens allowed
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Transfers `amount` tokens from `sender` to `recipient` using the allowance mechanism
    /// @param sender The address from which tokens are transferred
    /// @param recipient The address to which tokens are transferred
    /// @param amount The number of tokens to transfer
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /// @notice Emitted when `value` tokens are moved from one account (`from`) to another (`to`)
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted when the allowance of a `spender` for an `owner` is set by a call to `approve`
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/// @title SimpleSwap - A simplified Uniswap-like AMM for a single token pair without fees.
/// @author  
/// @notice Allows adding/removing liquidity, swapping tokens, getting prices and calculating output amounts.
/// @dev This contract handles a single pair of ERC20 tokens, with internal liquidity management and no fees.
contract SimpleSwap {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    uint256 private reserveA;
    uint256 private reserveB;

    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidityBalance;

    /// @notice Emitted when liquidity is added
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidityMinted);

    /// @notice Emitted when liquidity is removed
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidityBurned);

    /// @notice Emitted when tokens are swapped
    event TokensSwapped(address indexed swapper, uint256 amountIn, uint256 amountOut, address tokenIn, address tokenOut);

    /// @param _tokenA Address of tokenA
    /// @param _tokenB Address of tokenB
    constructor(address _tokenA, address _tokenB) {
        require(_tokenA != _tokenB, "Identical token addresses");
        require(_tokenA != address(0) && _tokenB != address(0), "Zero address tokens");
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    /// @notice Returns current reserves of tokenA and tokenB
    /// @return _reserveA Reserve of tokenA
    /// @return _reserveB Reserve of tokenB
    function getReserves() public view returns (uint256 _reserveA, uint256 _reserveB) {
        _reserveA = reserveA;
        _reserveB = reserveB;
    }

    /// @notice Adds liquidity to the pool
    /// @param amountADesired Desired amount of tokenA to add
    /// @param amountBDesired Desired amount of tokenB to add
    /// @param amountAMin Minimum amount of tokenA to add (slippage protection)
    /// @param amountBMin Minimum amount of tokenB to add (slippage protection)
    /// @param to Recipient of liquidity tokens
    /// @param deadline Unix timestamp after which the transaction will revert
    /// @return amountA Actual amount of tokenA added
    /// @return amountB Actual amount of tokenB added
    /// @return liquidity Liquidity tokens minted
    function addLiquidity(
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (uint256 amountA, uint256 amountB, uint256 liquidity)
    {
        require(block.timestamp <= deadline, "Transaction expired");
        require(to != address(0), "Invalid recipient");

        if (totalLiquidity == 0) {
            // Initial liquidity, add amounts as is
            amountA = amountADesired;
            amountB = amountBDesired;
        } else {
            // Maintain ratio according to current reserves
            uint256 amountBOptimal = (amountADesired * reserveB) / reserveA;
            if (amountBOptimal <= amountBDesired) {
                amountA = amountADesired;
                amountB = amountBOptimal;
            } else {
                uint256 amountAOptimal = (amountBDesired * reserveA) / reserveB;
                require(amountAOptimal <= amountADesired, "Insufficient A amount");
                amountA = amountAOptimal;
                amountB = amountBDesired;
            }
        }

        require(amountA >= amountAMin, "amountA < amountAMin");
        require(amountB >= amountBMin, "amountB < amountBMin");

        // Transfer tokens from sender
        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountA), "Transfer tokenA failed");
        require(IERC20(tokenB).transferFrom(msg.sender, address(this), amountB), "Transfer tokenB failed");

        // Mint liquidity proportional to min(amountA/reserveA, amountB/reserveB) * totalLiquidity
        if (totalLiquidity == 0) {
            liquidity = sqrt(amountA * amountB);
            require(liquidity > 0, "Insufficient liquidity minted");
        } else {
            uint256 liquidityA = (amountA * totalLiquidity) / reserveA;
            uint256 liquidityB = (amountB * totalLiquidity) / reserveB;
            liquidity = liquidityA < liquidityB ? liquidityA : liquidityB;
            require(liquidity > 0, "Insufficient liquidity minted");
        }

        liquidityBalance[to] += liquidity;
        totalLiquidity += liquidity;

        // Update reserves
        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(to, amountA, amountB, liquidity);
    }

    /// @notice Removes liquidity from the pool
    /// @param liquidity Amount of liquidity tokens to burn
    /// @param amountAMin Minimum amount of tokenA to receive
    /// @param amountBMin Minimum amount of tokenB to receive
    /// @param to Recipient of tokens
    /// @param deadline Unix timestamp after which the transaction will revert
    /// @return amountA Amount of tokenA sent to `to`
    /// @return amountB Amount of tokenB sent to `to`
    function removeLiquidity(
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (uint256 amountA, uint256 amountB)
    {
        require(block.timestamp <= deadline, "Transaction expired");
        require(to != address(0), "Invalid recipient");
        require(liquidity > 0, "Zero liquidity");
        require(liquidityBalance[msg.sender] >= liquidity, "Not enough liquidity");

        amountA = (liquidity * reserveA) / totalLiquidity;
        amountB = (liquidity * reserveB) / totalLiquidity;

        require(amountA >= amountAMin, "amountA < amountAMin");
        require(amountB >= amountBMin, "amountB < amountBMin");

        liquidityBalance[msg.sender] -= liquidity;
        totalLiquidity -= liquidity;

        reserveA -= amountA;
        reserveB -= amountB;

        require(IERC20(tokenA).transfer(to, amountA), "Transfer tokenA failed");
        require(IERC20(tokenB).transfer(to, amountB), "Transfer tokenB failed");

        emit LiquidityRemoved(msg.sender, amountA, amountB, liquidity);
    }

    /// @notice Swap exact amount of input tokens for as many output tokens as possible
    /// @param amountIn Amount of input tokens to send
    /// @param amountOutMin Minimum amount of output tokens expected
    /// @param path Array of token addresses (length = 2) [inputToken, outputToken]
    /// @param to Recipient of output tokens
    /// @param deadline Unix timestamp after which the transaction will revert
    /// @return amounts Array with [amountIn, amountOut]
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        returns (uint256[] memory amounts)
    {
        require(block.timestamp <= deadline, "Transaction expired");
        require(path.length == 2, "Path length must be 2");
        require(to != address(0), "Invalid recipient");

        address inputToken = path[0];
        address outputToken = path[1];

        require(
            (inputToken == address(tokenA) && outputToken == address(tokenB)) ||
            (inputToken == address(tokenB) && outputToken == address(tokenA)),
            "Invalid token path"
        );

        // Transfer input tokens from sender to contract
        IERC20(inputToken).transferFrom(msg.sender, address(this), amountIn);

        (uint256 reserveInput, uint256 reserveOutput) = inputToken == address(tokenA) 
            ? (reserveA, reserveB) 
            : (reserveB, reserveA);

        uint256 amountOut = getAmountOut(amountIn, reserveInput, reserveOutput);
        require(amountOut >= amountOutMin, "Insufficient output amount");

        // Update reserves
        if (inputToken == address(tokenA)) {
            reserveA += amountIn;
            reserveB -= amountOut;
        } else {
            reserveB += amountIn;
            reserveA -= amountOut;
        }

        // Transfer output tokens to recipient
        IERC20(outputToken).transfer(to, amountOut);

        amounts[0] = amountIn;
        amounts[1] = amountOut;

        emit TokensSwapped(msg.sender, amountIn, amountOut, inputToken, outputToken);
    }

    /// @notice Returns the current price of tokenA in terms of tokenB (price = reserveB / reserveA)
    /// @param _tokenA Address of tokenA (must be tokenA or tokenB)
    /// @param _tokenB Address of tokenB (must be tokenA or tokenB)
    /// @return price Price of one unit of _tokenA in terms of _tokenB
    function getPrice(address _tokenA, address _tokenB) external view returns (uint256 price) {
        require(
            (_tokenA == address(tokenA) && _tokenB == address(tokenB)) ||
            (_tokenA == address(tokenB) && _tokenB == address(tokenA)),
            "Invalid tokens"
        );

        if (_tokenA == address(tokenA)) {
            require(reserveA > 0, "No liquidity for tokenA");
            price = (reserveB * (10**18)) / reserveA; // scaled by 1e18 for decimals precision
        } else {
            require(reserveB > 0, "No liquidity for tokenB");
            price = (reserveA * (10**18)) / reserveB; // scaled by 1e18
        }
    }

    /// @notice Given an input amount of a token and pair reserves, returns the maximum output amount of the other token (no fee)
    /// @param amountIn Amount of input tokens
    /// @param reserveIn Reserve of input token
    /// @param reserveOut Reserve of output token
    /// @return amountOut Amount of output tokens
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256 amountOut) {
        require(amountIn > 0, "Insufficient input amount");
        require(reserveIn > 0 && reserveOut > 0, "Insufficient liquidity");

        // Formula without fee: amountOut = (amountIn * reserveOut) / (reserveIn + amountIn)
        amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    /// @notice Internal function to compute square root (Babylonian method)
    /// @param y Input value
    /// @return z Square root of y
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
