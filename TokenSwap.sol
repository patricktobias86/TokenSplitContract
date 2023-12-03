// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract TokenSwap {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Uniswap router for swapping tokens
    IUniswapV2Router02 public uniswapRouter;

    // Addresses of the tokens to swap into
    address public wethAddress;
    address public btcAddress;
    address public maticAddress;
    address public solAddress;

    constructor(
        address _uniswapRouter,
        address _wethAddress,
        address _btcAddress,
        address _maticAddress,
        address _solAddress
    ) {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        wethAddress = _wethAddress;
        btcAddress = _btcAddress;
        maticAddress = _maticAddress;
        solAddress = _solAddress;
    }

    // Function to deposit BNB and perform the token swap
    function depositAndSwap() external payable {
        uint256 amountToSwap = msg.value.div(4);

        _swapBNBForToken(wethAddress, amountToSwap);
        _swapBNBForToken(btcAddress, amountToSwap);
        _swapBNBForToken(maticAddress, amountToSwap);
        _swapBNBForToken(solAddress, amountToSwap);
    }

    // Internal function to perform the token swap on Uniswap
    function _swapBNBForToken(address tokenAddress, uint256 amount) internal {
        // Path for BNB -> Token swap
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = tokenAddress;

        // Perform the swap, sending the tokens to this contract
        uniswapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: amount }(
            0, // Accept any amount of Tokens
            path,
            address(this),
            block.timestamp.add(300)
        );
    }

    // Function to withdraw a specific token from the contract
    function withdrawToken(address tokenAddress) external {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(msg.sender, balance);
    }
}
