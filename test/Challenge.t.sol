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
        uint a = 0x100;
        uint b = 0x100;
        a = a - b + a;
        a = a >> 0x08;
        return a; // TODO
    }
}

contract OptimizedSolition {
    function owner() external pure returns (address) {
        return 0x00000000000000000000000000000000bEefbabe;
    }

    function solve(uint256) external returns (uint256) {
        return 1; // TODO
    }
}

contract ChallengeTest is Test {
    RewardNFT public nft;
    address public challenge;
    Solution public solution;
    OptimizedSolition public oSolution;

    function setUp() public {
        nft = new RewardNFT(address(this));
        challenge = HuffDeployer.config().with_addr_constant("NFT_ADDR", address(nft)).deploy("DovesInTheWind");
        solution = new Solution();
        oSolution = new OptimizedSolition();

        // Update owner to challenge contract address
        nft.transferOwnership(address(challenge));
    }

    ////////////////////////////////////////////////////////////////
    //                      CHALLENGE TESTS                       //
    ////////////////////////////////////////////////////////////////

    function testSolve() public {
        // Set msg.sender & tx.origin to beefbabe
        vm.startPrank(solution.owner(), solution.owner());

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
        (bool success,) = address(challenge).call(abi.encodeWithSelector(0x00000003, input));

        assertTrue(success);
        assertEq(nft.balanceOf(solution.owner()), 1);
        assertTrue(nft.ownerOf(0) == solution.owner());

        // Finish prank
        vm.stopPrank();

        // Solve again with a more optimized solution
        // ==========================================

        // Set msg.sender & tx.origin to beefbabe
        vm.startPrank(oSolution.owner(), oSolution.owner());

        // Create input with beefbabe's magic.
        // Will need to be changed once DovesInTheWind.huff has more code above
        // the magic_dest label, as the solution input's hash contains the desired jumpdest.
        magic = 0x800000001060c983;
        solAddr = address(oSolution);
        assembly {
            input := or(shl(0xC0, magic), solAddr)
        }

        // Call the challenge's third dispatch to get access to the wildcard logic.
        emit log_named_bytes("input", abi.encodeWithSelector(0x00000003, input));
        (success,) = address(challenge).call(abi.encodeWithSelector(0x00000003, input));

        assertTrue(success);
        assertEq(nft.balanceOf(oSolution.owner()), 2);
        assertTrue(nft.ownerOf(1) == oSolution.owner());

        // Finish prank
        vm.stopPrank();
    }

    function testFailSolveIncorrectMagic() public {
        // Set msg.sender & tx.origin to beefbabe
        vm.startPrank(solution.owner(), solution.owner());

        // Create input with beefbabe's magic.
        // Will need to be changed once DovesInTheWind.huff has more code above
        // the magic_dest label, as the solution input's hash contains the desired jumpdest.
        bytes32 input;
        uint256 magic = 0x800000001060c982;
        address solAddr = address(solution);
        assembly {
            input := or(shl(0xC0, magic), solAddr)
        }

        // Call the challenge's third dispatch to get access to the wildcard logic.
        emit log_named_bytes("input", abi.encodeWithSelector(0x00000003, input));
        (bool success,) = address(challenge).call(abi.encodeWithSelector(0x00000003, input));

        assertTrue(success);
        assertEq(nft.balanceOf(solution.owner()), 1);
        assertTrue(nft.ownerOf(0) == solution.owner());

        // Finish prank
        vm.stopPrank();
    }

    function testFailSolveLessOptimized() public {
        // Set msg.sender & tx.origin to beefbabe
        vm.startPrank(solution.owner(), solution.owner());

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
        (bool success,) = address(challenge).call(abi.encodeWithSelector(0x00000003, input));

        assertTrue(success);
        assertEq(nft.balanceOf(solution.owner()), 1);
        assertTrue(nft.ownerOf(0) == solution.owner());

        // Finish prank
        vm.stopPrank();

        // Solve again with a more optimized solution
        // ==========================================

        // Set msg.sender & tx.origin to beefbabe
        vm.startPrank(solution.owner(), solution.owner());

        // Create input with beefbabe's magic.
        // Will need to be changed once DovesInTheWind.huff has more code above
        // the magic_dest label, as the solution input's hash contains the desired jumpdest.
        magic = 0x800000001060c983;
        solAddr = address(solution);
        assembly {
            input := or(shl(0xC0, magic), solAddr)
        }

        // Call the challenge's third dispatch to get access to the wildcard logic.
        emit log_named_bytes("input", abi.encodeWithSelector(0x00000003, input));
        (success,) = address(challenge).call(abi.encodeWithSelector(0x00000003, input));

        assertTrue(success);
        assertEq(nft.balanceOf(solution.owner()), 2);
        assertTrue(nft.ownerOf(1) == solution.owner());

        // Finish prank
        vm.stopPrank();
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
