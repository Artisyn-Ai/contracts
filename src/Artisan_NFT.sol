// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "./OpenZeppelin/Ownable.sol";
import "./OpenZeppelin/ERC721Enumerable.sol";

contract Artisan_NFT is Ownable, ERC721Enumerable {
    address public creator;
    address public factory;
    address public admin;
    uint256 public allowedMintPerAddress;
    uint256 public maxSupply;
    uint256 public priceInWei; //in wei
    uint256 public fee; //5 default
    /**
        Minting State where:
        0 = Minting is off
        1 = Whitelist minting is enabled
        2 = Public minting is enabled
     */
    uint8 public mintingState = 0;
    mapping(address => bool) whitelistBool;

    constructor(
        address creator_,
        string memory name_, 
        string memory symbol_, 
        string memory baseURI_,
        uint256 tokensToCreator,
        uint256 allowedMinterPerAddress_,
        uint256 maxSupply_,
        uint256 priceInWei_,
        uint256 fee_
        )ERC721(name_, symbol_, baseURI_) {
        creator = creator_;
        factory = msg.sender;
        admin = Ownable(factory).owner();
        allowedMintPerAddress = allowedMinterPerAddress_;
        maxSupply = maxSupply_;
        priceInWei = priceInWei_;
        fee = fee_;
        _mint(msg.sender, tokensToCreator);
    }

    function whitelistAddresses(address[] memory whitelistAdds_) internal {
        for (uint256 i; i < whitelistAdds_.length; i++) {
            address user = whitelistAdds_[i];
            whitelistBool[user] = true;
        }
    }
    
    function changeMintStatus(uint8 newStatus) public returns(uint8) {
        require(msg.sender == creator);
        mintingState = newStatus;
        return mintingState;
    }

    function mintArtisan_NFT(uint256 quantityToMint) external payable {
        uint256 supply = totalSupply();
        require(quantityToMint > 0);
        require(supply + quantityToMint <= maxSupply, "Cannot mint more than max supply");
        require(quantityToMint <= allowedMintPerAddress, "Cannot mint more than permitted");
        require(msg.value >= priceInWei * quantityToMint, "Not enough ether");
        //Local storage variables
        //Revert if minting isnt enabled
        if (mintingState == 0) {
            revert("Minting is not enabled");
        } 
        //Whitelist minting logic
        else if (mintingState == 1 && whitelistBool[msg.sender]) {
            for (uint256 i; i < quantityToMint; i++) {
                _safeMint(msg.sender, supply++);
            }
        } 
        //Public minting logic
        else if (mintingState == 2) {
            for (uint256 i; i < quantityToMint; i++) {
                _safeMint(msg.sender, supply++);
            }
        }
    }

    function setPrice(uint256 newPriceInWei) public returns (uint256) {
        require(msg.sender == creator);
        priceInWei = newPriceInWei;
        return priceInWei;
    }

    function changeBaseURI(string memory newBaseURI) public returns (string memory) {
        require(msg.sender == admin);
        baseURI_ = newBaseURI;
        return baseURI_;
    }

  
    function withdraw() public payable {
        require(msg.sender == creator || msg.sender == owner());
        (bool hs, ) = payable(owner()).call{value: address(this).balance * fee / 100}("");
        require(hs);

        (bool os, ) = payable(creator).call{value: address(this).balance}("");
        require(os);
    }
}