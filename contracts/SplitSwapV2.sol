// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import '@uniswap/v2-core/contracts/interfaces/IERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

/**
 * @title Split swap
 * @notice Script to perform split swap in Uniswap V2
 */
contract SplitSwapV2 {

    // swap token0 to token1 by router,
    // the amount of each swap is equal to the size,
    // the amount of the last swap may be less than the size
    function splitSwap(address token0, address token1, address router, uint256 amount, uint256 size) public {

        require(amount > 0, 'SplitSwap: AMOUNT_IS_ZERO');
        require(size > 0, 'SplitSwap: SIZE_IS_ZERO');
        require(size <= amount, 'SplitSwap: SIZE_IS_MORE_THAN_AMOUNT');

        IERC20(token0).transferFrom(msg.sender, address(this), amount);
        IERC20(token0).approve(router, amount);
        
        address[] memory paths = new address[](2);

        paths[0] = token0;
        paths[1] = token1;

        while (amount > 0) {

            uint256 amountIn = amount < size ? amount : size;

            IUniswapV2Router02(router).swapExactTokensForTokens(
                amountIn, 
                0, 
                paths, 
                msg.sender,
                block.timestamp + 120);

            amount -= amountIn;
        }  
    }

    // swap token0 to token1 by router,
    // the token0 has transfer fee,
    // the amount of each swap is equal to the size,
    // the amount of the last swap may be less than the size
    function splitSwapSupportingTransferFee(address token0, address token1, address router, uint256 amount, uint256 size) public {

        require(amount > 0, 'SplitSwap: AMOUNT_IS_ZERO');
        require(size > 0, 'SplitSwap: SIZE_IS_ZERO');

        IERC20(token0).transferFrom(msg.sender, address(this), amount);

        amount = IERC20(token0).balanceOf(address(this));

        require(size <= amount, 'SplitSwap: SIZE_IS_MORE_THAN_AMOUNT');

        IERC20(token0).approve(router, amount);
        
        address[] memory paths = new address[](2);

        paths[0] = token0;
        paths[1] = token1;

        while (amount > 0) {

            uint256 amountIn = amount < size ? amount : size;

            IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountIn, 
                0, 
                paths, 
                msg.sender,
                block.timestamp + 120);

            amount -= amountIn;
        }  
    }
}
