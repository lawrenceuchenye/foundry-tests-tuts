// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {LinkToken} from "../../test/mocks/LinkToken.sol";

interface LinkTokenInterface {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract RaffleTest is Test {
    Raffle public raffle;

    event newEntry(address indexed entree, uint256 ethPush);

    address public player = makeAddr("PLAYER");
    LinkToken public lt;

    function setUp() public {
        lt = new LinkToken();
        raffle = new Raffle(0.001 ether, 30);
        vm.deal(player, 1 ether);
        vm.prank(address(this)); // Ensure the current contract (test contract) is sending the transaction
        lt.transfer(address(this), 1e18); // Mint 1 LINK token to this contract
    }

    function testChainlinkIntegration() public {
        uint256 linkBalanceBefore = lt.balanceOf(address(raffle));

        // Send LINK tokens to your contract
        lt.transfer(address(raffle), 1e18); // 1 LINK token (1e18 for 18 decimals)

        uint256 linkBalanceAfter = lt.balanceOf(address(raffle));

        // Assert the LINK token transfer was successful
        assert(linkBalanceAfter > linkBalanceBefore);
        console.log(lt.balanceOf(address(raffle)));
        // Run your contract's logic that uses Chainlink oracles
        // e.g., interacting with Chainlink Data Feed contracts

        // Assert your expected outcomes from using Chainlink
    }

    function test_initIsOpen() public {
        assert(raffle.getRafState() == Raffle.RafState.isOpen);
    }

    function test_NoFeesNoEntry() public {
        vm.prank(player);
        vm.expectRevert(Raffle.NotEnoughEthToEnter.selector);
        raffle.enterRaf();
    }

    function test_PlayerAdmit() public {
        vm.prank(player);
        raffle.enterRaf{value: 0.001 ether}();
        assert(raffle.getPlayer(0) == player);
    }

    function test_EmitPlayerAdded() public {
        //A1
        vm.prank(player);

        //A2
        vm.expectEmit(true, true, false, false, address(raffle)); // Check topics 1 and 2 (from, to)
        emit newEntry(player, 0.001 ether);

        //A3
        raffle.enterRaf{value: 0.004 ether}();
    }


    /*function test_PickWinner() public {
        //A1
        vm.prank(player);
        uint256 raffleBalanceBefore = lt.balanceOf(address(raffle));
        vm.prank(address(raffle)); // Ensure the current contract (test contract) is sending the transaction
        lt.transfer(address(raffle), 1e18); // Mint 1 LINK token to this contract

        console.log("Raffle contract balance before: ", raffleBalanceBefore);
    }*/

    function test_upKeepNeeded() public{
        vm.warp(block.timestamp+30+1);
        vm.roll(block.number+1);
        (bool upkeepNeeded,)=raffle.checkUpkeep("");
        assert(!upkeepNeeded);
    }

    function test_upKeepReturnedFalseIfNotOpen() public{
        vm.prank(player);
           raffle.enterRaf{value: 0.004 ether}();
           raffle.setRaffleToCal();
  vm.warp(block.timestamp+30+1);
        vm.roll(block.number+1);

        (bool upkeepNeeded,)=raffle.checkUpkeep("");
        assert(!upkeepNeeded);
    }
}
