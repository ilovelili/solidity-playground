// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract Oracle {
    struct Result {
        bool exist;
        uint256 payload;
        address[] approvedBy;
    }
    
    address[] public validators;
    mapping(bytes32 => Result) public results;
    
    constructor(address[] memory _validators) {
        validators = _validators;
    }
    
    function feedData(bytes32 _dataKey, uint256 _payload) external onlyValidator() {
        address[] memory _approvedBy = new address[](1);
        _approvedBy[0] = msg.sender;
        require(!results[_dataKey].exist, 'This data was already imported before');
        results[_dataKey] = Result(true, _payload, _approvedBy);
    }
    
    function approveData(bytes32 _dataKey) external onlyValidator() {
        Result storage result = results[_dataKey];
        require(result.exist, "datakey not exist");
        for (uint256 i = 0; i < result.approvedBy.length; i++) {
            require(result.approvedBy[i] != msg.sender, 'Cannot approve same data twice');
        }
        result.approvedBy.push(msg.sender);
    }
    
    function getData(bytes32 _dataKey) external view returns (Result memory) {
        return results[_dataKey];
    }
    
    modifier onlyValidator() {
        bool isValidator = false;
        for(uint i = 0; i < validators.length; i++) {
            if(validators[i] == msg.sender) isValidator = true;
        }
        require(isValidator, "Only validator allowed");
        _;
    }
}