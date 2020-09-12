// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

interface ERC20Interface {
    function transfer(address to, uint256 amount) external returns (bool success);
    function transferFrom(address from, address to, uint256 amount) external returns (bool success);
    function balanceOf(address owner) external view returns (uint256 amount);
    function approve(address spender, uint256 amount) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint256 amount);
    function totalSupply() external view returns (uint256 amount);
    
    event Transfer(address indexed from, address indexed to, uint256 indexed amount);
    event Approval(address indexed owner, address indexed spender, uint256 indexed amount);
}


contract ERC20Token is ERC20Interface {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public supply;
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _supply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        supply = _supply;
        balances[msg.sender] = supply;
    }
    
    function transfer(address to, uint256 amount) override external returns (bool success) {
        require(balances[msg.sender] >= amount, "not enough balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) override external returns (bool success) {
        uint256 allowance = allowed[from][msg.sender];
        require(allowance >= 0, "not enough balance");
        balances[from] -= amount;
        balances[to] += amount;
        allowed[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }
    
    function approve(address to, uint256 amount) override external returns (bool success) {
        require(to != msg.sender, "cannot approve yourself");
        allowed[msg.sender][to] = amount;
        emit Approval(msg.sender, to, amount);
        return true;
    }
    
    function allowance(address from, address to) override external view returns(uint256 amount) {
        return allowed[from][to];
    }
    
    function balanceOf(address owner) override external view returns (uint256 amount) {
        return balances[owner];
    }
    
    function totalSupply() override external view returns (uint256) {
        return supply;
    }
}

contract ICO {
    struct Sale {
        address investor;
        uint256 amount;
    }
    
    Sale[] public sales;
    mapping(address => bool) public investors;
    address public token;
    address public admin;
    uint256 public end;
    uint256 public price;
    uint256 public availableTokens;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    bool public released;
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _supply
    ) {
        token = address(new ERC20Token(_name, _symbol, _decimals, _supply));
        admin = msg.sender;
    }
    
    function start(
        uint _duration,
        uint _price,
        uint _availableTokens,
        uint _minPurchase,
        uint _maxPurchase
    ) external onlyAdmin() icoNotActive() {
        require(_duration > 0, 'duration should be > 0');
        uint256 totalSupply = ERC20Token(token).totalSupply();
        require(_availableTokens > 0 && _availableTokens <= totalSupply, 'totalSupply should be > 0 and <= totalSupply');
        require(_minPurchase > 0, '_minPurchase should > 0');
        require(_maxPurchase > 0 && _maxPurchase <= _availableTokens, '_maxPurchase should be > 0 and <= _availableTokens');
        end = _duration + block.timestamp;
        price = _price;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        availableTokens = _availableTokens;
    }
    
    function whitelist(address investor) external onlyAdmin() {
        investors[investor] = true;
    }
    
    function buy() external payable onlyInvestors() icoActive() {
        require(msg.value % price == 0, 'have to send a multiple of price');
        require(msg.value >= minPurchase && msg.value <= maxPurchase, 'have to send between minPurchase and maxPurchase');
        uint256 amount = price * msg.value;
        require(amount <= availableTokens, 'Not enough tokens left for sale');
        sales.push(Sale(msg.sender, amount));
    }
    
    function release() external onlyAdmin() icoEnded() tokensNotReleased() {
        ERC20Token tokenInstance = ERC20Token(token);
        for (uint256 i = 0; i < sales.length; i++) {
            Sale storage sale = sales[i];
            // should use withdraw pattern instead
            tokenInstance.transfer(sale.investor, sale.amount);
        }
        released = true;
    }
    
    function withdraw(address payable to, uint amount) external onlyAdmin() icoEnded() tokensReleased() {
        to.transfer(amount);    
    }
    
    modifier onlyAdmin() {
        require(admin == msg.sender, "only admin allowed");
        _;
    }
    
    modifier onlyInvestors() {
        require(investors[msg.sender], "only investors allowed");
        _;
    }
    
    modifier icoActive() {
        require(end > 0 && block.timestamp < end && availableTokens > 0, "ICO must be active");
        _;
    }
    
    modifier icoNotActive() {
        require(end == 0, 'ICO should not be active');
        _;
    }
    
    modifier icoEnded() {
        require(end > 0 && (block.timestamp >= end || availableTokens == 0), 'ICO must have ended');
        _;
    }
    
    modifier tokensReleased() {
        require(released == true, 'Tokens must have been released');
        _;
    }
    
    modifier tokensNotReleased() {
        require(released == false, 'Tokens must NOT have been released');
        _;
    }
}