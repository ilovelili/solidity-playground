// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Crud {
    struct User {
        uint256 id;
        string name;
    }
    
    User[] public users;
    uint256 public nextId = 1;
    
    function create(string memory name) public {
        users.push(User(nextId, name));
        nextId++;
    }
    
    function read(uint256 id) public view returns(uint256, string memory) {
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i].id == id) {
                return (users[i].id, users[i].name);
            }
        }
    }
    
    function update(uint256 id, string memory name) public {
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i].id == id) {
                users[i].name = name;
            }
        }
    }
    
    function destroy(uint256 id) public {
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i].id == id) {
                delete users[i];
            }
        }
    }
}