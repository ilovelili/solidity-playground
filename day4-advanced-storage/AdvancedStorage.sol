// SPDX-License-Identifier: ISC
pragma solidity ^0.6.0;

contract AdvancedStorage {
  uint256[] public ids;

  function add(uint256 _id) public {
    ids.push(_id);
  }

  function get(uint256 index) public view returns (uint256) {
    return ids[index];
  }

  function getAll() public view returns (uint256[] memory) {
    return ids;
  }

  function length() public view returns (uint256) {
    return ids.length;
  }
}
