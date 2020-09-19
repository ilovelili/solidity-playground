// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Dex {
    mapping(string => uint256) private prices;
    
    function getPrice(string calldata _sticker) external view returns (uint256) {
        return prices[_sticker];
    }
    
    function buy(string memory _sticker, uint256 amount, uint256 price) external {
        // buy erc20 token
    }
    
    function sell(string memory _sticker, uint256 amount, uint256 price) external {
        // sell erc20 token
    }
}