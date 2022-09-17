pragma solidity ^0.8.17;

import {ERC721} from "solmate/tokens/ERC721.sol";

/// @title Reward NFT
///
contract RewardNFT is ERC721 {
    ////////////////////////////////////////////////////////////////
    //                         VARIABLES                          //
    ////////////////////////////////////////////////////////////////

    address public owner;
    uint256 public currentId;

    ////////////////////////////////////////////////////////////////
    //                           ERRORS                           //
    ////////////////////////////////////////////////////////////////

    error OnlyOwner();

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

    constructor(address _owner) ERC721("Whitenoise Challenge #1", "WNC1") {
        owner = _owner;
    }

    ////////////////////////////////////////////////////////////////
    //                          EXTERNAL                          //
    ////////////////////////////////////////////////////////////////

    function tokenURI(uint256 id) public view override returns (string memory) {
        // TODO
        return "";
    }

    /// @notice Mints a new NFT to the given address
    /// @dev Only callable by the owner of this contract (DovesInTheWind.huff)
    function mint(address _to) external onlyOwner {
        _safeMint(_to, currentId++);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
}
