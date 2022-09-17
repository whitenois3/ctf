// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface IChallenge {
// TODO
}

contract Solution {
    function owner() external pure returns (address) {
        return 0x00000000000000000000000000000000bEefbabe;
    }

    function solve(uint256) external returns (uint256) {
        return 0; // TODO
    }
}

contract ChallengeTest is Test {
    IChallenge public challenge;
    Solution public solution;

    function setUp() public {
        challenge = IChallenge(HuffDeployer.config().deploy("DovesInTheWind"));
        solution = new Solution();
    }

    function testSolve() public {
        // Set tx.origin to beefbabe
        vm.startPrank(address(this), address(0x00000000000000000000000000000000bEefbabe));

        // Create input with beefbabe's magic.
        // Will need to be changed once DovesInTheWind.huff has more code above
        // the magic_dest label, as the solution input's hash contains the desired jumpdest.
        bytes32 input;
        uint256 magic = 0x4000000010f2def3;
        address solAddr = address(solution);
        assembly {
            input := or(shl(0xC0, magic), solAddr)
        }

        // Call the challenge's third dispatch to get access to the wildcard logic.
        emit log_named_bytes("input", abi.encodeWithSelector(0x00000003, input));
        (bool success, bytes memory a) = address(challenge).call(abi.encodeWithSelector(0x00000003, input));
        assertTrue(success);

        address returned;
        assembly {
            returned := mload(add(a, 0x20))
        }
        assertEq(returned, address(solution));
    }
}
