// SPDX-License-Identifier: GPL-3.0 
pragma solidity >=0.7.0 <0.9.0; 

contract PayableDemo { 
    uint256 public balance; 
    uint256 public number = 11111; 

    address payable public owner;

    event Instructor(string name, uint256 age);
    // 部署合约的人 类型转换 
    constructor() { 
        // 部署这个合约的时候 管理权给我了 
        owner = payable(msg.sender); 
    } 

    // 测试写入
    function testWriteNumber() public { 
        number += 1111;
    } 

    function deposit() public payable { 
        // 存钱 用户实际传递过来的金额 
        balance += msg.value; 
    } 

    // 算法 帮他赚5%-8%收益 
    // aave uniswap compound yearn finance sushi dydx curve 

    // 谁存的钱谁才能取 
    function withdraw(uint256 amount, address _to) public { 
        // 你收取1%-3%的服务费 
        // 取钱 只能合约拥有者取钱 你得是管理员 
        require(msg.sender == owner, "only owner can withdraw"); 

        // 余额不足 
        require(amount <= balance, "insufficient balance"); 

        // 给用户转账 
        // owner.transfer(amount); 
        payable(_to).transfer(amount); 

        balance -= amount; 
    } 
}