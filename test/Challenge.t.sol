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

    function testSetup() public {
        emit log_named_address("challenge_addr", address(challenge));
        uint not_zero;
        assembly {
            not_zero := not(1000000)
        }
        address(challenge).call(abi.encodePacked(bytes4(0x00000000), not_zero));
        address(challenge).call(abi.encode(bytes4(0x00000001)));
    }
}
