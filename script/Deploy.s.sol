pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "foundry-huff/HuffDeployer.sol";

import { WhitenoiseNFT } from "src/WhitenoiseNFT.sol";

contract Deploy is Script {
    function run() external {
        vm.broadcast();
        WhitenoiseNFT nft = new WhitenoiseNFT();

        address challenge = HuffDeployer
            .config()
            .set_broadcast(true)
            .with_addr_constant("NFT_ADDR", address(nft))
            .deploy("DovesInTheWind");

        vm.broadcast();
        nft.transferOwnership(challenge);
    }
}
