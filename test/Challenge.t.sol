// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {WhitenoiseNFT} from "../src/WhitenoiseNFT.sol";
import {Test} from "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

/// @notice Solution interface
interface ISolution {
    function owner() external virtual returns (address);

    function solve(uint256) external virtual returns (uint256);
}

/// @notice An unoptimized solution
contract Solution is ISolution {
    function owner() external pure returns (address) {
        return 0x00000000000000000000000000000000bEefbabe;
    }

    /// @dev Sum all even bytes in received word
    function solve(uint256 word) external returns (uint256) {
        uint256 acc;

        for (uint256 i = 0; i < 32; i++) {
            uint256 masked = word & 0xFF;

            if (masked % 2 == 0) {
                acc += masked;
            }

            word >>= 0x08;
        }

        return acc;
    }
}

/// @notice An optimized solution
contract OptimizedSolution is ISolution {
    function owner() external pure returns (address) {
        return 0x00000000000000000000000000000000bEefbabe;
    }

    /// @dev Hard-code answer to 1958 on local anvil testnet
    function solve(uint256 word) external returns (uint256) {
        uint256 acc;
        uint256 masked;

        assembly {
            for { let i := 0 } lt(i, 0x20) { i := add(i, 0x01) } {
                masked := and(word, 0xFF)

                if iszero(mod(masked, 0x02)) { acc := add(acc, masked) }

                word := shr(0x08, word)
            }
        }

        return acc;
    }
}

/// @notice Challenge Tests
contract ChallengeTest is Test {
    uint256 constant BEEFBABE_MAGIC = 0x400000004cf81335;

    WhitenoiseNFT public nft;
    address public challenge;

    Solution public solution;
    OptimizedSolution public oSolution;

    function setUp() public {
        // Deploy as a random EOA
        vm.startPrank(address(0xDEADBEEF));

        // Deploy RewardNFT and `DovesInTheWind` Challenge
        nft = new WhitenoiseNFT();
        challenge = HuffDeployer.config().with_addr_constant("NFT_ADDR", address(nft)).deploy("DovesInTheWind");

        // Update owner to challenge contract address
        nft.transferOwnership(address(challenge));

        // Deploy solutions
        solution = new Solution();
        oSolution = new OptimizedSolution();

        // Drop prank
        vm.stopPrank();
    }

    ////////////////////////////////////////////////////////////////
    //                      CHALLENGE TESTS                       //
    ////////////////////////////////////////////////////////////////

    function testCallChallengeFromEOA() public {
        vm.prank(solution.owner());
        (bool success,) = address(challenge).call(abi.encodeWithSelector(0, uint256(1)));
        assertTrue(success);
    }

    function testSolve() public {
        // Attempt first solution
        solve(solution.owner(), address(solution), BEEFBABE_MAGIC);

        // Assert that we've received a reward NFT for our efforts
        address owner = ISolution(solution).owner();
        assertEq(nft.balanceOf(owner), 1);
        assertTrue(nft.ownerOf(1) == owner);
        assertIsTheChad(solution.owner(), 9008);

        // Attempt second solution with an optimized solution contract
        solve(oSolution.owner(), address(oSolution), BEEFBABE_MAGIC);
        assertIsTheChad(oSolution.owner(), 4081);
    }

    function testFailCallChallengeFromContract() public {
        (bool success,) = address(challenge).call(abi.encodeWithSelector(0, uint256(1)));
        assertTrue(success);
    }

    function testFailSolveAfterChallengeIsOver() public {
        vm.warp(14 days + 1 seconds);

        // Attempt first solution
        solve(solution.owner(), address(solution), BEEFBABE_MAGIC);
    }

    function testFailSolveIncorrectMagic() public {
        // Attempt solution with incorrect magic (will fail)
        solve(solution.owner(), address(solution), BEEFBABE_MAGIC - 1);
    }

    function testFailSolveLessOptimized() public {
        // Attempt first solution
        solve(solution.owner(), address(solution), BEEFBABE_MAGIC);

        // Assert that we've received a reward NFT for our efforts
        address owner = ISolution(solution).owner();
        assertEq(nft.balanceOf(owner), 1);
        assertTrue(nft.ownerOf(1) == owner);
        assertIsTheChad(solution.owner(), 9008);

        // Attempt solution with the same amount of gas / bytecode size
        solve(solution.owner(), address(solution), BEEFBABE_MAGIC);
    }

    ////////////////////////////////////////////////////////////////
    //                      REWARD NFT TESTS                      //
    ////////////////////////////////////////////////////////////////

    function testClaimChadNFT() public {
        // Attempt first solution
        solve(solution.owner(), address(solution), BEEFBABE_MAGIC);

        // Assert that we've received a reward NFT for our efforts
        address owner = ISolution(solution).owner();
        assertEq(nft.balanceOf(owner), 1);
        assertTrue(nft.ownerOf(1) == owner);
        assertIsTheChad(solution.owner(), 9008);

        vm.warp(14 days + 1 seconds);
        vm.prank(solution.owner());
        nft.claim();

        // Assert that we've received a reward NFT for our efforts
        assertEq(nft.balanceOf(owner), 2);
        assertTrue(nft.ownerOf(2) == owner);
    }

    function testFailClaimChadNFTTwice() public {
        // Attempt first solution
        solve(solution.owner(), address(solution), BEEFBABE_MAGIC);

        // Assert that we've received a reward NFT for our efforts
        address owner = ISolution(solution).owner();
        assertEq(nft.balanceOf(owner), 1);
        assertTrue(nft.ownerOf(1) == owner);
        assertIsTheChad(solution.owner(), 9008);

        vm.warp(14 days + 1 seconds);
        vm.prank(solution.owner());
        nft.claim();
        nft.claim();
    }

    function testFailClaimChadNFTBeforeEnd() public {
        // Attempt first solution
        solve(solution.owner(), address(solution), BEEFBABE_MAGIC);

        // Assert that we've received a reward NFT for our efforts
        address owner = ISolution(solution).owner();
        assertEq(nft.balanceOf(owner), 1);
        assertTrue(nft.ownerOf(1) == owner);
        assertIsTheChad(solution.owner(), 9008);

        vm.warp(12 days);
        vm.prank(solution.owner());
        nft.claim();
    }

    function testFailClaimChadNFTNotWinner() public {
        // Attempt first solution
        solve(solution.owner(), address(solution), BEEFBABE_MAGIC);

        // Assert that we've received a reward NFT for our efforts
        address owner = ISolution(solution).owner();
        assertEq(nft.balanceOf(owner), 1);
        assertTrue(nft.ownerOf(1) == owner);
        assertIsTheChad(solution.owner(), 9008);

        vm.warp(14 days + 1 seconds);
        vm.prank(address(0xdeadbeef));
        nft.claim();
    }

    // Should fail because the test contract is not the owner.
    function testFailTransferNFTOwnership() public {
        nft.transferOwnership(address(this));
    }

    // Should fail because the owner cannot be changed after it has been set
    // to a contract.
    function testFailTransferNFTOwnershipFromChallenge() public {
        vm.prank(address(challenge));
        nft.transferOwnership(address(this));
    }

    // Should fail because solutions can only be submitted by `Challenge`
    function testFailSubmitSolution() public {
        nft.submit(address(solution.owner()), 0, 0);
    }

    ////////////////////////////////////////////////////////////////
    //                          HELPERS                           //
    ////////////////////////////////////////////////////////////////

    /// @notice Helper to submit a solution to the Challenge contract.
    function solve(address from, address solution, uint256 magic) internal {
        // Set msg.sender & tx.origin to `from`
        vm.startPrank(from, from);

        // Create input with 0xbeefbabe's magic.
        // Will need to be changed once DovesInTheWind.huff has more code above
        // the magic_dest label, as the solution input's hash contains the desired jumpdest.
        bytes32 input;
        assembly {
            input := or(shl(0xC0, magic), solution)
        }

        // Call the challenge's third dispatch to get access to the wildcard logic.
        (bool success,) = address(challenge).call(abi.encodeWithSelector(0x00000003, input));

        // Assert that the call was a success.
        assertTrue(success);

        // Finish prank
        vm.stopPrank();
    }

    function assertIsTheChad(address solver, uint256 score) internal {
        WhitenoiseNFT.Chad memory theChad = nft.theChad();

        assertEq(theChad.solver, solver);
        assertEq(theChad.score, score);
    }
}
