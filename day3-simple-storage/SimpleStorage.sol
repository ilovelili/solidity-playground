// SPDX-License-Identifier: ISC
pragma solidity ^0.6.0;

contract SimpleStorage {
  string public data;

  function set(string memory _data) public {
    data = _data;
  }
}
