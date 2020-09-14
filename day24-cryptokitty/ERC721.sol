// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

library AddressUtils {
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) } // solhint-disable-line
        return size > 0;
    }
}

interface IERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

interface IERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address from, address to, uint256 tokenId) external payable;
    function transferFrom(address from, address to, uint256 tokenId) external payable;
    function approve(address approved, uint256 tokenId) external payable;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract ERC721Token is IERC721 {
    using AddressUtils for address;
    // default is internal
    mapping(address => uint256) private ownerToTokenCount;
    mapping(uint256 => address) private idToOwner;
    mapping(uint256 => address) private idToApproved;
    mapping(address => mapping(address => bool)) private ownerToOperators;
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;
    mapping(uint256 => string) private tokenURIs;
    string public name;
    string public symbol;
    string public tokenURIBase;
    
    constructor(
      string memory _name, 
      string memory _symbol,
      string memory _tokenURIBase) {
      name = _name;
      symbol = _symbol;
      tokenURIBase = _tokenURIBase;
    }
    
    function tokenURI(uint tokenId) external view returns(string memory) {
      return string(abi.encodePacked(tokenURIBase, tokenId));
    }
    
    function balanceOf(address owner) override external view returns(uint256) {
        return ownerToTokenCount[owner];
    }
    
    function ownerOf(uint256 tokenId) override external view returns (address) {
        return idToOwner[tokenId];
    }
    
    function safeTransferFrom(address from, address to, uint tokenId, bytes calldata data) override external payable {
        _safeTransferFrom(from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint tokenId) override external payable {
        _safeTransferFrom(from, to, tokenId, ""); 
    }
    
    function transferFrom(address from, address to, uint tokenId) override external payable {
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
    
    function _safeTransferFrom(address from, address to, uint tokenId, bytes memory data) internal {
       _transfer(from, to, tokenId);
        
        if(to.isContract()) {
            bytes4 retval = IERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, data);
            require(retval == MAGIC_ON_ERC721_RECEIVED, 'recipient SC cannot handle ERC721 tokens');
        }
    }
    
    function _transfer(address from, address to, uint tokenId) internal canTransfer(tokenId) {
        ownerToTokenCount[from] -= 1; 
        ownerToTokenCount[to] += 1;
        idToOwner[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }
    
    function _mint(address owner, uint tokenId) internal {
        require(idToOwner[tokenId] == address(0), 'This token already exist..');
        idToOwner[tokenId] = owner;
        ownerToTokenCount[owner] += 1;
        emit Transfer(address(0), owner, tokenId);
    }
    
    modifier canTransfer(uint tokenId) {
        address owner = idToOwner[tokenId];
        require(owner == msg.sender 
            || idToApproved[tokenId] == msg.sender
            || ownerToOperators[owner][msg.sender], 'Transfer not authorized');
        _;
    }
}