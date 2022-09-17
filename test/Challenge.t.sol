// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RewardNFT} from "../src/RewardNFT.sol";
import {Test} from "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract Solution {
    function owner() external pure returns (address) {
        return 0x00000000000000000000000000000000bEefbabe;
    }

    function solve(uint256) external returns (uint256) {
        return 0; // TODO
    }
}

contract ChallengeTest is Test {
    RewardNFT public nft;
    address public challenge;
    Solution public solution;

    function setUp() public {
        nft = new RewardNFT(address(this));
        challenge = HuffDeployer.config().with_addr_constant("NFT_ADDR", address(nft)).deploy("DovesInTheWind");
        solution = new Solution();

        // Update owner to challenge contract address
        nft.transferOwnership(address(challenge));
    }

    ////////////////////////////////////////////////////////////////
    //                      CHALLENGE TESTS                       //
    ////////////////////////////////////////////////////////////////

    function testSolve() public {
        // Set tx.origin to beefbabe
        vm.startPrank(address(this), solution.owner());

        // Create input with beefbabe's magic.
        // Will need to be changed once DovesInTheWind.huff has more code above
        // the magic_dest label, as the solution input's hash contains the desired jumpdest.
        bytes32 input;
        uint256 magic = 0x800000001060c983;
        address solAddr = address(solution);
        assembly {
            input := or(shl(0xC0, magic), solAddr)
        }

        // Call the challenge's third dispatch to get access to the wildcard logic.
        emit log_named_bytes("input", abi.encodeWithSelector(0x00000003, input));
        (bool success, bytes memory res) = address(challenge).call(abi.encodeWithSelector(0x00000003, input));
        assertTrue(success);

        address returned;
        assembly {
            returned := mload(add(res, 0x20))
        }
        assertEq(returned, solAddr);
    }

    ////////////////////////////////////////////////////////////////
    //                      REWARD NFT TESTS                      //
    ////////////////////////////////////////////////////////////////

    // Should fail because the Challenge contract is the owner.
    function testFailTransferNFTOwnership() public {
        nft.transferOwnership(address(this));
    }

    // Should fail because the Challenge contract is the owner.
    function testFailMintNFT() public {
        nft.mint(address(solution.owner()));
    }
}
