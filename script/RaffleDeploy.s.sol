// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract RaffleScript is Script {
    Raffle public raffle;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        raffle = new Raffle(0.001 ether, 30);

        vm.stopBroadcast();
    }
}
