// SPDX-License-Identifier: MIT

pragma solidity 0.8.29;

import "forge-std/Test.sol";
import "../src/LeepCoin.sol";

contract LeepCoinTest is Test {
    LeepCoin public leepCoin;
    // 0x0000000000000000000000000000000000000001
    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    uint256 public initialSupply = 1000000; // 100W ether

    function setUp() public {
        vm.prank(owner); // 创建者
        leepCoin = new LeepCoin(initialSupply);
    }

    // 初始化
    function testInitialSetup() public {
        // 测试代币基本信息
        assertEq(leepCoin.name(), "LeepCoin");
        assertEq(leepCoin.symbol(), "LEEP");
        assertEq(leepCoin.decimals(), 18);
        
        // 测试初始供应量
        uint256 expectedTotalSupply = initialSupply * 10 ** 18;
        assertEq(leepCoin.totalSupply(), expectedTotalSupply);
        
        // 测试初始余额分配
        assertEq(leepCoin.balanceOf(owner), expectedTotalSupply);
    }

    // 转账
    function testTransfer() public {
        uint256 transferAmount = 100 * 10 ** 18;
        
        vm.prank(owner);
        bool success = leepCoin.transfer(user1, transferAmount);
        console.log(leepCoin.balanceOf(owner));
        
        assertTrue(success);
        assertEq(leepCoin.balanceOf(owner), initialSupply * 10 ** 18 - transferAmount);
        assertEq(leepCoin.balanceOf(user1), transferAmount);
    }

    // 授权
    function testApprove() public {
        uint256 approveAmount = 500 * 10 ** 18;
        
        vm.prank(owner); // 授权的操作不一定是owner 可以是任何人
        // 授权给银行
        bool success = leepCoin.approve(user1, approveAmount);
        
        assertTrue(success);
        assertEq(leepCoin.allowance(owner, user1), approveAmount);
    } 

    function testTransferFrom() public {
        uint256 transferAmount = 200 * 10 ** 18;
        
        // 先授权
        vm.prank(owner);
        leepCoin.approve(user1, transferAmount);
        
        // 然后从授权账户转账
        vm.prank(user1);
        bool success = leepCoin.transferFrom(owner, user2, transferAmount);
        
        assertTrue(success);
        assertEq(leepCoin.balanceOf(owner), initialSupply * 10 ** 18 - transferAmount);
        assertEq(leepCoin.balanceOf(user2), transferAmount);
        assertEq(leepCoin.allowance(owner, user1), 0);
    }

    function testTransferFromInsufficientAllowance() public {
        uint256 approveAmount = 100 * 10 ** 18;
        uint256 transferAmount = 200 * 10 ** 18;
        
        vm.prank(owner);
        leepCoin.approve(user1, approveAmount);
        
        vm.prank(user1);
        vm.expectRevert("Insufficient allowance");
        leepCoin.transferFrom(owner, user2, transferAmount);
    }

    function testTransferFromInsufficientBalance() public {
        vm.prank(owner);
        leepCoin.approve(user1, 1000 * 10 ** 18);
        
        // 尝试转账超过用户余额的数量
        vm.prank(user1);
        vm.expectRevert("Insufficient balance");
        leepCoin.transferFrom(owner, user2, (initialSupply + 1) * 10 ** 18);
    }

    function testEventTransfer() public {
        uint256 transferAmount = 100 * 10 ** 18;
        
        vm.prank(owner);
        vm.expectEmit(true, true, false, false);
        emit LeepCoin.Transfer(owner, user1, transferAmount);
        leepCoin.transfer(user1, transferAmount);
    }

    function testEventApproval() public {
        uint256 approveAmount = 500 * 10 ** 18;
        
        vm.prank(owner);
        vm.expectEmit(true, true, false, false);
        emit LeepCoin.Approval(owner, user1, approveAmount);
        leepCoin.approve(user1, approveAmount);
    }
}