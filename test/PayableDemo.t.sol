// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "forge-std/Test.sol";
import "../src/PayableDemo.sol";

contract PayableDemoTest is Test {
    PayableDemo public payableDemo;
    address public owner;
    address public user1;
    address public user2;
    uint256 public constant INITIAL_BALANCE = 10 ether;

    function setUp() public {
        owner = address(this);
        user1 = address(0x123);
        user2 = address(0x456);
        
        // 部署合约
        payableDemo = new PayableDemo();
    }

    // 测试合约部署时owner设置正确
    function testOwner() public {
        assertEq(payableDemo.owner(), owner);
    }

    // 测试存款功能
    function testDeposit() public {
        uint256 depositAmount = 1 ether;
        
        // 调用deposit函数并存入1 ether
        payableDemo.deposit{value: depositAmount}();
        
        // 检查余额是否正确
        assertEq(payableDemo.balance(), depositAmount);
    }

    // 测试多次存款功能
    function testMultipleDeposits() public {
        uint256 depositAmount1 = 1 ether;
        uint256 depositAmount2 = 2 ether;
        uint256 depositAmount3 = 3 ether;
        
        // 第一次存款
        payableDemo.deposit{value: depositAmount1}();
        assertEq(payableDemo.balance(), depositAmount1);
        
        // 第二次存款
        payableDemo.deposit{value: depositAmount2}();
        assertEq(payableDemo.balance(), depositAmount1 + depositAmount2);
        
        // 第三次存款
        payableDemo.deposit{value: depositAmount3}();
        assertEq(payableDemo.balance(), depositAmount1 + depositAmount2 + depositAmount3);
    }

    // 测试只有owner可以取款
    function testOnlyOwnerCanWithdraw() public {
        uint256 depositAmount = 1 ether;
        uint256 withdrawAmount = 0.5 ether;
        
        // 存款
        payableDemo.deposit{value: depositAmount}();
        
        // 切换到user1调用withdraw，应该失败
        vm.prank(user1);
        vm.expectRevert("only owner can withdraw");
        payableDemo.withdraw(withdrawAmount, user1);
    }

    // 测试余额不足时取款失败
    function testWithdrawInsufficientBalance() public {
        uint256 depositAmount = 1 ether;
        uint256 withdrawAmount = 2 ether;
        
        // 存款
        payableDemo.deposit{value: depositAmount}();
        
        // 尝试取出超过余额的金额，应该失败
        vm.expectRevert("insufficient balance");
        payableDemo.withdraw(withdrawAmount, owner);
    }

    // 测试正常取款功能
    function testWithdraw() public {
        uint256 depositAmount = 1 ether;
        uint256 withdrawAmount = 0.5 ether;
        
        // 存款
        payableDemo.deposit{value: depositAmount}();
        
        // 记录user1初始余额
        uint256 user1InitialBalance = address(user1).balance;
        
        // 取款到user1
        payableDemo.withdraw(withdrawAmount, user1);
        
        // 检查合约余额是否正确减少
        assertEq(payableDemo.balance(), depositAmount - withdrawAmount);
        
        // 检查user1余额是否正确增加
        assertEq(address(user1).balance, user1InitialBalance + withdrawAmount);
    }

    // 测试取款到不同地址
    function testWithdrawToDifferentAddresses() public {
        uint256 depositAmount = 3 ether;
        
        // 存款
        payableDemo.deposit{value: depositAmount}();
        
        // 分别向user1和user2转账
        payableDemo.withdraw(1 ether, user1);
        payableDemo.withdraw(1 ether, user2);
        
        // 检查合约余额
        assertEq(payableDemo.balance(), 1 ether);
        
        // 检查user1和user2的余额
        assertEq(address(user1).balance, 1 ether);
        assertEq(address(user2).balance, 1 ether);
    }

    // 测试合约接收以太币的能力
    function testReceiveEther() public {
        // 直接向合约发送以太币，应该失败因为合约没有receive或fallback函数
        (bool success,) = address(payableDemo).call{value: 1 ether}("");
        assertFalse(success);
    }

    // 测试合约余额与状态变量balance的一致性
    function testContractBalanceConsistency() public {
        uint256 depositAmount = 2 ether;
        
        // 存款
        payableDemo.deposit{value: depositAmount}();
        
        // 检查合约余额
        uint256 contractBalance = address(payableDemo).balance;
        
        // 检查状态变量balance
        uint256 stateBalance = payableDemo.balance();
        
        // 两者应该相等
        assertEq(contractBalance, stateBalance);
    }
}