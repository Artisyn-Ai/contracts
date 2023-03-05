// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "./OpenZeppelin/Ownable.sol";
import "./Artisan_NFT.sol";

contract NFT_Factory is Ownable {
    mapping(address => address[]) createdNFTs;
    uint256 createdNFTCount;
    uint256 mintFee;
    uint256 fee;  //set as 5 default

    constructor(uint256 mintFee_, uint256 fee_) {
        mintFee = mintFee_;
        fee = fee_;
    }
    
    function createERC721(
        address creator_,
        string memory name_, 
        string memory symbol_, 
        string memory baseURI_,
        uint256 tokensToCreator,
        uint256 allowedMinterPerAddress_,
        uint256 maxSupply_,
        uint256 pricePerAsset_
    ) public payable returns(Artisan_NFT) {
        require(msg.value >= mintFee);
        Artisan_NFT newNFT = new Artisan_NFT(
            creator_,
            name_, 
            symbol_, 
            baseURI_,
            tokensToCreator,
            allowedMinterPerAddress_,
            maxSupply_,
            pricePerAsset_,
            fee
        );
        createdNFTs[msg.sender].push(address(newNFT));
        return newNFT;
    }

    event MintingStatusChanged(Artisan_NFT Artisan_NFT_Add, uint8 newStatus);

    function changeMintingStatus(uint8 newStatus, Artisan_NFT Artisan_NFT_Add) public returns (uint8) {
        require(Artisan_NFT_Add.creator() == msg.sender, "Only the creator can call this contract");
        require(newStatus == 0 || newStatus == 1 || newStatus == 2, "You must enter a valid status uint");
        //Update the status
        Artisan_NFT_Add.changeMintStatus(newStatus);

        emit MintingStatusChanged(Artisan_NFT_Add, newStatus);
        return newStatus;
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

}