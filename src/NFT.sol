// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Strings} from "@openzeppelin/utils/Strings.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    // Counter to keep track of token IDs
    uint256 private tokenIdCounter;

    // Mapping to store the original creator of each NFT
    mapping(uint256 => address) private creators;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        tokenIdCounter = 0;
    }

    // Mint a new NFT and assign it to the specified owner
    function mint(address _to) public onlyOwner {
        uint256 tokenId = tokenIdCounter++;
        _mint(_to, tokenId);
        creators[tokenId] = _to;
    }

    // Transfer an NFT to a new owner
    function transfer(address _to, uint256 _tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "Not the owner or approved");
        _transfer(_msgSender(), _to, _tokenId);
    }

    // Get the creator of an NFT
    function getCreator(uint256 _tokenId) public view returns (address) {
        return creators[_tokenId];
    }
}
