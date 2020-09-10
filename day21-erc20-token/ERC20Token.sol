// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

interface ERC20Interface {
    function transfer(address to, uint256 amount) external returns (bool success);
    function transferFrom(address from, address to, uint256 amount) external returns (bool success);
    function banalceOf(address owner) external view returns (uint256);
    // https://stackoverflow.com/questions/48664570/what-approve-and-allowance-methods-are-really-doing-in-erc20-standard/48664889
    // When calling the approve function, you allow the spenderAddress to spend approveValue tokens on your behalf.
    function approve(address spender, uint256 amount) external returns (bool approved);
    // The allowance function tells how many tokens the ownerAddress has allowed the spenderAddress to spend.
    function allowance(address owner, address spender) external view returns (uint256 amount);
    function totalSupply() external view returns (uint);
    
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 amount);
}

contract ERC20Token is ERC20Interface {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public supply;
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint _totalSupply) {
            name = _name;
            symbol = _symbol;
            decimals = _decimals;
            supply = _totalSupply;
            balances[msg.sender] = _totalSupply;
        }
        
    // override modifier is needed...
    // https://github.com/ethereum/solidity/issues/8281
    function transfer(address to, uint256 amount) external override(ERC20Interface) returns (bool success) {
        require(balances[msg.sender] >= amount, "not enough balanace");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external override(ERC20Interface) returns (bool success) {
        uint256 allowance = allowed[from][msg.sender];
        require(balances[from] >= amount && allowance >= amount, "not enough balance");
        allowed[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) external override(ERC20Interface) returns (bool approved) {
        require(spender != msg.sender, "cannot approve yourself");
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function allowance(address owner, address spender) external view override(ERC20Interface) returns (uint256 amount) {
        return allowed[owner][spender];
    }
    
    function banalceOf(address owner) external view override(ERC20Interface) returns (uint256 amount) {
        return balances[owner];
    }
    
    function totalSupply() external view override(ERC20Interface) returns (uint) {
        return supply;
    }
}