//SPDX-License-Identifier: MIT

pragma solidity 0.8.29;
contract LeepCoin {
    // 代币基本信息
    string public name = "LeepCoin";
    string public symbol = "LEEP";
    uint8 public decimals = 18;
    uint256 public totalSupply; // 100W * 10 18次方wei

    // 余额映射 
    // mapping(用户1 => 余额) mapping(用户2 => 余额) mapping(用户3 => 余额)
    mapping(address => uint256) public balanceOf;
    // 授权映射（谁授权给谁多少额度）
    //  mapping(用户1 => mapping(机构1 => 授权额度)) 
    //  mapping(用户1 => mapping(机构2 => 授权额度)) 
    //  mapping(用户2 => mapping(机构1 => 授权额度)) 
    //  mapping(用户2 => mapping(机构2 => 授权额度)) 
    mapping(address => mapping(address => uint256)) public allowance;

    // 事件定义
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 构造函数，初始化代币总量并分配给合约创建者
    constructor(uint256 initialSupply) {
        // 相当于mint
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // 转账公共函数
    function _transfer(address from, address to, uint256 value) public {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(to != address(0), "Cannot transfer to zero address");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    // 转账函数
    function transfer(address to, uint256 value) public returns (bool success) {
        require(to != address(0), "Cannot transfer to zero address");
        _transfer(msg.sender, to, value);
        return true;
    }

    // 授权函数
    function approve(address spender, uint256 value) public returns (bool success) {
        require(spender != address(0), "Cannot approve to zero address");
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // 授权转账函数
    // msg.sender:L, user1, E, 100
    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        // from 某一个放款账户地址
        // to 收款账户
        // msg.sender 交易所
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");

        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }
}