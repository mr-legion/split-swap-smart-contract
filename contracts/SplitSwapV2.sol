// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import '@uniswap/v2-core/contracts/interfaces/IERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

contract SplitSwap {

    address owner;

    constructor() {
       owner = msg.sender;
    }

    function approve(address token, address router, uint256 amount) public {
        require(msg.sender == owner, 'Uniswap: NOT_OWNER');
        IERC20(token).approve(router, amount);
    }

    function withdraw(address token) public {
        require(msg.sender == owner, 'Uniswap: NOT_OWNER');
        uint balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }

    function splitSwap(address token0, address token1, address router, uint256 amount, uint256 size) public {

        require(msg.sender == owner, 'Uniswap: NOT_OWNER');
        
        address[] memory paths = new address[](2);

        paths[0] = token0;
        paths[1] = token1;

        while (amount > 0) {

            uint amountIn = amount < size ? amount : size;
            uint amountOut = 0;

            IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountIn, 
                amountOut, 
                paths, 
                msg.sender,
                block.timestamp + 120);

            amount = amount - amountIn;
        }  
    }
}
