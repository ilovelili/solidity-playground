// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Loop {
    function sumInSolidity(uint256[] memory _data) pure public returns(uint sum) {
        for (uint256 i = 0; i < _data.length; i++) {
            sum += _data[i];
        }
    }
    
    function sumInAssembly(uint[] memory _data) pure public returns(uint sum) {
        assembly {
            // Load the length (first 32 bytes)
            let len := mload(_data)
            
            // Skip over the length field
            // 0x20 needs to be added to an array because the first slot contains the array length.
            let data := add(_data, 0x20)
            
            for { let end := add(data, mul(len, 0x20)) } lt(data, end) { data := add(data, 0x20) } {
                sum := add(sum, mload(data))
            }
        }
    }
    
}