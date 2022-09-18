// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RewardNFT} from "../src/RewardNFT.sol";
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

    function solve(uint256) external returns (uint256) {
        uint256 a = 0x100;
        uint256 b = 0x100;
        a = a - b + a;
        a = a >> 0x08;
        return a; // TODO
    }
}

/// @notice An optimized solution
contract OptimizedSolution is ISolution {
    function owner() external pure returns (address) {
        return 0x00000000000000000000000000000000bEefbabe;
    }

    function solve(uint256) external returns (uint256) {
        return 1; // TODO
    }
}

/// @notice Challenge Tests
contract ChallengeTest is Test {
    RewardNFT public nft;
    address public challenge;

    Solution public solution;
    OptimizedSolution public oSolution;

    function setUp() public {
        // Deploy as a random EOA
        vm.startPrank(address(0xDEADBEEF));

        // Deploy RewardNFT and `DovesInTheWind` Challenge
        nft = new RewardNFT();
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

    function testSolve() public {
        // Attempt first solution
        solve(solution.owner(), address(solution), 0x800000001060c983, 1);

        // Attempt second solution with an optimized solution contract
        solve(oSolution.owner(), address(oSolution), 0x800000001060c983, 2);
    }

    function testFailSolveIncorrectMagic() public {
        // Attempt solution with incorrect magic (will fail)
        solve(solution.owner(), address(solution), 0x800000001060c982, 1);
    }

    function testFailSolveLessOptimized() public {
        // Attempt first solution
        solve(solution.owner(), address(solution), 0x800000001060c983, 1);

        // Attempt solution with the same amount of gas / bytecode size
        solve(solution.owner(), address(solution), 0x800000001060c983, 2);
    }

    ////////////////////////////////////////////////////////////////
    //                      REWARD NFT TESTS                      //
    ////////////////////////////////////////////////////////////////

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

    // Should fail because the test contract is not the owner of the NFT
    // contract.
    function testFailMintNFT() public {
        nft.mint(address(solution.owner()), 0, 0);
    }

    ////////////////////////////////////////////////////////////////
    //                          HELPERS                           //
    ////////////////////////////////////////////////////////////////

    /// @notice Helper to submit a solution to the Challenge contract.
    function solve(address from, address solution, uint256 magic, uint256 id) internal {
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

        // Assert that we've received a reward NFT for our efforts
        address owner = ISolution(solution).owner();
        assertEq(nft.balanceOf(owner), id);
        assertTrue(nft.ownerOf(id) == owner);

        // Finish prank
        vm.stopPrank();
    }
}
