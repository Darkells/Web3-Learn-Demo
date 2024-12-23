// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract MiniUniSwap is ERC20 {

    address public token0;

    address public token1;

    uint public reserve0;

    uint public reserve1;

    uint public constant INITIAL_SUPPLY = 10**5;
    
    constructor(address _token0, address _token1) ERC20("MiniUniSwap", "LP") {
        token0 = _token0;
        token1 = _token1;
    }

    /**
     * @dev Add liquidity to the pool
     * @param amount0 Amount of token0 to add
     * @param amount1 Amount of token1 to add
     * @return liquidity Amount of LP tokens minted
     */
    function addLiquidity(uint amount0, uint amount1) external returns (uint liquidity) {
        require(amount0 > 0 && amount1 > 0, 'INSUFFICIENT_AMOUNT');
        uint totalSupply = totalSupply();
        if (totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - INITIAL_SUPPLY;
            _mint(msg.sender, INITIAL_SUPPLY);
        } else {
            liquidity = Math.min(amount0 * totalSupply / reserve0, amount1 * totalSupply / reserve1);
        }
        _mint(msg.sender, liquidity);
        reserve0 += amount0;
        reserve1 += amount1;
    }

    /**
     * @dev Remove liquidity from the pool
     * @param liquidity Amount of LP tokens to burn
     * @return amount0 Amount of token0 received
     * @return amount1 Amount of token1 received
     */
    function removeLiquidity(uint liquidity) external returns (uint amount0, uint amount1) {
        require(liquidity > 0 && totalSupply() >= liquidity, 'INSUFFICIENT_LIQUIDITY');
        amount0 = liquidity * reserve0 / totalSupply();
        amount1 = liquidity * reserve1 / totalSupply();
        _burn(msg.sender, liquidity);
        reserve0 -= amount0;
        reserve1 -= amount1;
    }

    /**
     * @dev Swap tokens
     * @param amountIn Amount of token to swap
     * @param tokenIn Token to swap
     * @param tokenOut Token to receive
     * @return amountOut Amount of token received
     */
    function swap(uint amountIn, address tokenIn, address tokenOut) external returns (uint amountOut) {
        require(tokenIn == token0 || tokenIn == token1, 'INVALID_TOKEN_IN');
        require(tokenOut == token0 || tokenOut == token1, 'INVALID_TOKEN_OUT');
        require(amountIn > 0, 'INSUFFICIENT_AMOUNT');
        uint amountInWithFee = amountIn * 997;
        require(amountOut > 0, 'INSUFFICIENT_OUTPUT_AMOUNT');
        if (tokenOut == token0) {
            reserve0 += amountInWithFee;
            reserve1 -= amountOut;
        } else {
            reserve1 += amountInWithFee;
            reserve0 -= amountOut;
        }
        ERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        ERC20(tokenOut).transfer(msg.sender, amountOut);
    }

    /**
     * @dev Get the price of token0 in terms of token1
     * @return price Price of token0 in terms of token1
     */
    function getPrice() external view returns (uint price) {
        return reserve1 * 1e18 / reserve0;
    }


    /**
     * @dev Get the reserves of the pool
     * @return reserve0 Reserve of token0
     * @return reserve1 Reserve of token1
     */
    function getReserves() external view returns (uint, uint) {
        return (reserve0, reserve1);
    }

}