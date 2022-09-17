// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface IChallenge {
    // TODO
}

contract ChallengeTest is Test {
    IChallenge public challenge;
    
    function setUp() public {
        challenge = IChallenge(
            HuffDeployer.config().deploy("DovesInTheWind")
        );
    }

    // TODO
}
