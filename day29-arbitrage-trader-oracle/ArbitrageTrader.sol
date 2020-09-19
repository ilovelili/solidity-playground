// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import './Dex.sol';
import './Oracle.sol';

contract ArbitrageTrader {
    struct Asset {
        string name;
        address dex;
    }
    
    mapping(string => Asset) public assets;
    address public admin;
    address public oracle;
    
    constructor() {
        admin = msg.sender;
    }
    
    function configoracle(address _oracle) external onlyAdmin() {
        oracle = _oracle;
    }
    
    function configAssets(Asset[] calldata _assets) external onlyAdmin() {
        for (uint256 i = 0; i < _assets.length; i++) {
            assets[_assets[i].name] = Asset(_assets[i].name, _assets[i].dex);
        }
    }
    
    function maybeTrade(string calldata _sticker, uint _date) external onlyAdmin() {
        Asset storage asset = assets[_sticker];
        require(asset.dex != address(0), "This asset doesnot exist");
        
        // Get latest price of asset from oracle
        bytes32 dataKey = keccak256(abi.encodePacked(_sticker, _date));
        Oracle oracleContract = Oracle(oracle);
        Oracle.Result memory result = oracleContract.getData(dataKey);
        
        require(result.exist == true, 'This result does not exist, cannot trade');
        require(result.approvedBy.length == 10, 'Not enough approvals for this result, cannot trade');
        
        // If there is a price, trade of the dex
        Dex dexContract = Dex(asset.dex);
        uint256 price = dexContract.getPrice(_sticker);
        uint256 amount = 1 ether / price; // todo: safemath
        
        if(price > result.payload) {
            dexContract.sell(_sticker, amount, (99 * price) / 100);
        } else if(price < result.payload) {
            dexContract.buy(_sticker, amount, (101 * price) / 100);
        }
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
}