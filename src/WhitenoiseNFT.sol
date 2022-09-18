pragma solidity ^0.8.17;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";

/// @title Whitenoise NFT
/// @author clabby <https://github.com/clabby>
contract WhitenoiseNFT is ERC721, ReentrancyGuard {
    ////////////////////////////////////////////////////////////////
    //                         VARIABLES                          //
    ////////////////////////////////////////////////////////////////

    /// @notice The owner of the NFT contract (Should be the challenge contract!)
    address public owner;

    /// @notice The total supply of the NFT
    uint256 public currentId;

    ////////////////////////////////////////////////////////////////
    //                           ERRORS                           //
    ////////////////////////////////////////////////////////////////

    /// @notice Error thrown when a function protected by the `onlyOwner`
    ///         modifier is called by an address that is not the owner.
    error OnlyOwner();

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

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }

    ////////////////////////////////////////////////////////////////
    //                        CONSTRUCTOR                         //
    ////////////////////////////////////////////////////////////////

    constructor() ERC721("Doves in the Wind", "WNC1") {
        owner = msg.sender;

        bool creatorIsEOA;
        assembly {
            creatorIsEOA := iszero(extcodesize(caller()))
        }
        
        // If the creator is an EOA, mint the creator edition (id = 0) and deploy as normal.
        // else, revert.
        if (creatorIsEOA) {
            _safeMint(msg.sender, 0);

            assembly {
                sstore(currentId.slot, add(sload(currentId.slot), 0x01))
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
    function tokenURI(uint256 id) public view override returns (string memory) {
        // Check for creator special edition
        if (id == 0) {
            // TODO
            return "";
        }

        // Check for first solver special edition
        if (id == 1) {
            // TODO
            return "";
        }

        // Optimizer challenge editions
        // TODO
        return "";
    }

    /// @notice Mints a new NFT to the given address.
    /// @dev Only callable by the owner of this contract (DovesInTheWind.huff)
    function mint(address _to, uint256 gasUsed, uint256 codeSize) external onlyOwner nonReentrant {
        uint256 _currentId = currentId;

        // Mint the solver's NFT.
        _safeMint(_to, _currentId);

        // If this is the first solve, emit a `FirstSolve` event with their address.
        if (_currentId == 1) {
            emit FirstSolve(_to);
        }

        // Emit a `NewLeader` event.
        emit NewLeader(_to, gasUsed, codeSize);

        // Update the currentId.
        // It is unrealistic that this will ever overflow.
        assembly {
            sstore(currentId.slot, add(_currentId, 0x01))
        }
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
}
