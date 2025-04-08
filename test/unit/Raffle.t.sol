// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";

contract RaffleTest is Test {
    Raffle public raffle;

    event newEntry(address indexed entree, uint256 ethPush);

    address public player = makeAddr("PLAYER");

    function setUp() public {
        raffle = new Raffle(0.001 ether, 30);
        vm.deal(player, 1 ether);
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
        vm.expectEmit(true,true,false,false,address(raffle)); // Check topics 1 and 2 (from, to)
        emit newEntry(player, 0.001 ether);

        //A3
        raffle.enterRaf{value: 0.004 ether}();
    }

    function test_PickWinner() public{
        //A1
        vm.prank(player);

        //A2
         raffle.enterRaf{value: 0.004 ether}();
         vm.warp(block.timestamp+30+1);
         vm.roll(block.number+1);

         //A3
         raffle.pickWinner();
    }
}
