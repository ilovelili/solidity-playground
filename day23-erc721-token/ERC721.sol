// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

library AddressUtils {
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        // there is no better way to check if there is a contract in an address than to check the size of the code at that address
        assembly { size := extcodesize(addr) }  // solhint-disable-line
        return size > 0;
    }
}

interface IERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns(bytes4);
}

// NFT (Non Fungible Token) https://eips.ethereum.org/EIPS/eip-721
interface IERC721 {
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address from, address to, uint256 tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address from, address to, uint256 tokenId) external payable;
    // Enable or disable approval for a third party ("operator") to manage all of `msg.sender`'s assets
    function approve(address to, uint256 tokenId) external payable;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract ERC721Token is IERC721 {
    using AddressUtils for address;
    
    mapping(address => uint256) private ownerToTokenCount;
    mapping(uint256 => address) private idToOwner;
    mapping(uint256 => address) private idToApproved;
    mapping(address => mapping(address => bool)) private ownerToOperators;
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;
    
    function balanceOf(address owner) override external view returns(uint) {
        return ownerToTokenCount[owner];
    }
    
    function ownerOf(uint256 tokenId) override external view returns (address) {
        return idToOwner[tokenId];
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) override external payable {
        _safeTransferFrom(from, to, tokenId, data);
    }
    
    function safeTransferFrom(address from, address to, uint tokenId) override external payable {
        _safeTransferFrom(from, to, tokenId, ""); 
    }
    
    function transferFrom(address from, address to, uint tokenId) external payable {
        _transfer(from, to, tokenId);
    }
    
    function approve(address approved, uint tokenId) override external payable {
        address owner = idToOwner[tokenId];
        require(msg.sender == owner, 'Not authorized');
        idToApproved[tokenId] = approved;
        emit Approval(owner, approved, tokenId);
    }
    
    function setApprovalForAll(address operator, bool approved) override external {
        ownerToOperators[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    function getApproved(uint tokenId) override external view returns (address) {
        return idToApproved[tokenId];
    }
    
    function isApprovedForAll(address owner, address operator) override external view returns (bool) {
        return ownerToOperators[owner][operator];
    }
    
    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) internal {
       _transfer(from, to, tokenId);
        if(to.isContract()) {
            bytes4 retval = IERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, data);
            require(retval == MAGIC_ON_ERC721_RECEIVED, 'recipient smart contract cannot handle ERC721 tokens');
        }
    }
    
    function _transfer(address from, address to, uint tokenId) internal canTransfer(tokenId) {
        ownerToTokenCount[from] -= 1; 
        ownerToTokenCount[to] += 1;
        idToOwner[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }
    
    modifier canTransfer(uint256 tokenId) {
        address owner = idToOwner[tokenId];
        require(owner == msg.sender 
            || idToApproved[tokenId] == msg.sender
            || ownerToOperators[owner][msg.sender], 'Transfer not authorized');
        _;
    }
}