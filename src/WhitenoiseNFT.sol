pragma solidity ^0.8.17;

import { Base64 } from "./utils/Base64.sol";

import { ERC721 } from "solmate/tokens/ERC721.sol";
import { ReentrancyGuard } from "solmate/utils/ReentrancyGuard.sol";

/// @title Whitenoise Challenge NFT
/// @author clabby <https://github.com/clabby>
/// @author asnared <https://github.com/abigger87>
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠈⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢷⣤⡀⠀⠉⠛⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⡀⠀⠉⠁⠀⠀⠀⠀⠈⠙⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠋⠁⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡛⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⠟⠛⠋⠉⠉⠁⠀⢀⣠⣴⠾⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡶⠖⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠠⣤⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⠀⠀⠀⠀⠀⠀⠀⠠⣀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⣠⠀⠀⠀⠀⠀⠀⠀⠀⠻⠀⠀⠀⠀⠀⠀⠀⠀⢈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⠶⠂⠀⠀⠀⠀⢀⡄⠀⠀⠀⡀⠀⣱⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠋⠉⠁⠀⠀⠀⠀⠀⠀⠀⠙⢿⣷⣶⣶⣾⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠶⠒⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣴⠂⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣀⣴⠇⠀⢠⡇⠀⠀⣶⠀⠀⢧⡀⢈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣤⣿⡇⠀⢰⣿⣇⣀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
/// ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
contract WhitenoiseNFT is ERC721, ReentrancyGuard {
    ////////////////////////////////////////////////////////////////
    //                         VARIABLES                          //
    ////////////////////////////////////////////////////////////////

    uint256 public immutable END_TIME;

    /// @notice The owner of the NFT contract (Should be the challenge contract!)
    address public owner;

    /// @notice The total supply of the NFT
    uint256 public currentId;

    /// @notice The number of chads who have solved the challenge.
    uint256 public numChads;

    /// @notice Stores all solutions.
    ///         The last Chad submitted the most optimized solver.
    ///         The first Chad is the initial exploiter.
    mapping(uint256 => Chad) public leaderboard;

    ////////////////////////////////////////////////////////////////
    //                          STRUCTS                           //
    ////////////////////////////////////////////////////////////////

    struct Chad {
        address solver;
        uint128 score;
        uint64 gasUsed;
        uint64 codeSize;
    }

    ////////////////////////////////////////////////////////////////
    //                           ERRORS                           //
    ////////////////////////////////////////////////////////////////

    /// @notice Error thrown when a function protected by the `onlyOwner`
    ///         modifier is called by an address that is not the owner.
    error OnlyOwner();

    /// @notice Error thrown when a function that can only be executed
    ///         during the challenge is executed afterwards.
    error OnlyDuringChallenge();

    /// @notice Error thrown when a function that can only be executed
    ///         after the challenge has completed is executed beforehand.
    error OnlyAfterChallenge();

    /// @notice Error thrown when an EOA who is not the Chad attempts
    ///         to claim the Optimizer NFT after the Challenge has concluded.
    error NotTheChad();

    /// @notice Error thrown when the max NFT supply has been reached.
    error MaxSupply();

    /// @notice Error thrown if transfer function is called.
    error Soulbound();

    ////////////////////////////////////////////////////////////////
    //                           EVENTS                           //
    ////////////////////////////////////////////////////////////////

    /// @notice Event emitted when the first solve occurs.
    event FirstSolve(address indexed solver);

    /// @notice Event emitted when a new optimal solution has been submitted.
    event NewLeader(address indexed solver, uint256 gasUsed, uint256 codeSize);

    ////////////////////////////////////////////////////////////////
    //                         MODIFIERS                          //
    ////////////////////////////////////////////////////////////////

    /// @notice Asserts that msg.sender is the owner.
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }

    ////////////////////////////////////////////////////////////////
    //                        CONSTRUCTOR                         //
    ////////////////////////////////////////////////////////////////

    constructor() ERC721("Doves in the Wind", "DOVE") {
        END_TIME = block.timestamp + 21 days;

        bool creatorIsEOA;
        assembly {
            creatorIsEOA := iszero(extcodesize(caller()))
        }

        // If the creator is an EOA, mint the creator edition (id = 0) and deploy as normal.
        // else, revert.
        if (creatorIsEOA) {
            _mintyFresh(msg.sender, 0);
            assembly {
                sstore(owner.slot, caller())
            }
        } else {
            assembly {
                revert(0x00, 0x00)
            }
        }
    }

    ////////////////////////////////////////////////////////////////
    //                          EXTERNAL                          //
    ////////////////////////////////////////////////////////////////

    /// @notice Get the token URI of a token ID
    function tokenURI(uint256 id) public pure override returns (string memory) {
        string memory name = "Optimizer";
        string memory description = "A Soulbound token demonstrating a mastery in optimization and evm wizardry";
        string memory img_url = "ipfs://QmT5v6ioQMUHgsYXTXL8oAaVAitxqK6NE7Q5bacUzTVgbA";

        // Check for creator special edition
        if (id == 0) {
            name = "Deployer";
            description = "Special Edition for the WhitenoiseNFT Deployer";
            img_url = "ipfs://QmR82jC87jEtgJFxhbUBThJCcavDCwut21VD3TvHSXsp43";
        }

        // Check for first solver special edition
        if (id == 1) {
            name = "Chad";
            description = "Special Edition Token for the first solver";
            img_url = "ipfs://QmT2vXZ52LTFfXPn6YAffHsWik5bYRFrp744rqbCaKy18i";
        }

        // Base64 Encode our JSON Metadata
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        name,
                        '", "description": "',
                        description,
                        '", "image": "',
                        img_url,
                        '", "external_url": "https://ctf.whitenoise.rs"}'
                    )
                )
            )
        );

        // Prepend data:application/json;base64 to define the base64 encoded data
        return string(
            abi.encodePacked("data:application/json;base64,", json)
        );
    }

    /// @notice Returns the current Chad.
    function theChad() public view returns (Chad memory chad) {
        uint256 _numChads = numChads;
        if (_numChads == 0) {
            return Chad({
                solver: address(0),
                score: type(uint128).max,
                gasUsed: type(uint64).max,
                codeSize: type(uint64).max
            });
        } else {
            return leaderboard[_numChads - 1];
        }
    }

    /// @notice Claim Optimizer NFT after the game has concluded.
    function claim() external {
        // Assert that the challenge has concluded.
        if (block.timestamp < END_TIME) {
            revert OnlyAfterChallenge();
        }

        Chad memory chad = theChad();
        if (chad.solver == msg.sender) {
            _mintyFresh(msg.sender, currentId);
        } else {
            revert NotTheChad();
        }
    }

    ////////////////////////////////////////////////////////////////
    //                           ADMIN                            //
    ////////////////////////////////////////////////////////////////

    /// @notice Submit a new solution.
    /// @dev Only callable by the owner of this contract (DovesInTheWind.huff)
    function submit(address _solver, uint256 gasUsed, uint256 codeSize)
        external
        onlyOwner
        nonReentrant
    {
        // Assert that the the challenge is not over
        if (block.timestamp >= END_TIME) {
            revert OnlyDuringChallenge();
        }

        uint256 _currentId = currentId;

        // If this is the first solve, emit a `FirstSolve` event with their address
        // and mint their NFT.
        if (_currentId == 1) {
            _mintyFresh(_solver, _currentId);
            emit FirstSolve(_solver);
        }

        // Copy `numChads` to the stack
        uint256 _numChads = numChads;

        // Add the new leader to the leaderboard.
        leaderboard[_numChads] = Chad({
            solver: _solver,
            score: uint128(gasUsed + codeSize),
            gasUsed: uint64(gasUsed),
            codeSize: uint64(codeSize)
        });

        // Increase number of Chads.
        // SAFETY: It is unrealistic that this will ever overflow.
        assembly {
            sstore(numChads.slot, add(_numChads, 0x01))
        }

        // Emit a `NewLeader` event.
        emit NewLeader(_solver, gasUsed, codeSize);
    }

    /// @notice Administrative function to transfer the ownership of the contract
    ///         over to the Challenge contract.
    function transferOwnership(address _newOwner) external onlyOwner {
        assembly {
            // Don't allow ownership transfer to a non-contract.
            if iszero(extcodesize(_newOwner)) { revert(0x00, 0x00) }

            // Once the owner is set to a contract, it can no longer be changed.
            if iszero(iszero(extcodesize(sload(owner.slot)))) { revert(0x00, 0x00) }
        }

        // Update the owner to a contract.
        owner = _newOwner;
    }

    ////////////////////////////////////////////////////////////////
    //                          INTERNAL                          //
    ////////////////////////////////////////////////////////////////

    // Make the NFT Soulbound by overriding transfer functionality
    function transferFrom(address, address, uint256) public override {
        revert Soulbound();
    }

    function _mintyFresh(address _to, uint256 _currentId) internal {
        if (currentId > 2) {
            revert MaxSupply();
        }

        // Safe Mint NFT with current ID
        _safeMint(_to, _currentId);

        // Update the currentId.
        // SAFETY: It is unrealistic that this will ever overflow.
        assembly {
            sstore(currentId.slot, add(_currentId, 0x01))
        }
    }
}
