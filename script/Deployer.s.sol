// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "../lib/forge-std/src/Script.sol";
import "../src/NFT_Factory.sol";
import "../src/Artisan_NFT.sol";

contract Deployer is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        NFT_Factory factory = new NFT_Factory(0.01 * 1e18 , 5);

        address[] memory t = new address[](1);
        t[0] = 0x78232130fE188c42CdB0dEE379877f7726e3CB2e;

        Artisan_NFT newNFT = factory.createERC721{value: 0.01 ether}(
            0x78232130fE188c42CdB0dEE379877f7726e3CB2e, 
            "The Pea Car", 
            "pcar", 
            "https://asylumsfx.com/wp-content/uploads/2014/12/Pea-Car-05-1140x760.jpg", 
            0,
            10, 
            10, 
            0.01 * (10**18)
        );

        factory.changeMintingStatus(2, newNFT);

        newNFT.mintArtisan_NFT{value: 0.02 ether}(2);

        vm.stopBroadcast();
    }
}
