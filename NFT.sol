// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

 
contract NFT is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address private marketplaceAddress;
    mapping(uint256 => address) private _creators;

    mapping(address => uint[]) createdPerWallet;
    mapping(address => uint[]) ownedPerWallet;

    event TokenMinted(uint256 indexed tokenId, string tokenURI, address marketplaceAddress);

    constructor(address _marketplaceAddress) ERC721("MarkKop", "MARK") {
        marketplaceAddress = _marketplaceAddress;
    }

    function mintToken(string memory _tokenURI) public returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _tokenIds.increment();
        _mint(msg.sender, newItemId);
        _creators[newItemId] = msg.sender;
        createdPerWallet[msg.sender].push(newItemId);
        ownedPerWallet[msg.sender].push(newItemId);
        _setTokenURI(newItemId, _tokenURI);

        //  this is to Give the marketplace approval to transact NFTs between users
        setApprovalForAll(marketplaceAddress, true);

        emit TokenMinted(newItemId, _tokenURI, marketplaceAddress);
        return newItemId;
    }

    function getTokensOwnedByMe() public view returns (uint256[] memory) {
        uint256 numberOfTokensOwned = balanceOf(msg.sender);
        uint256[] memory ownedTokenIds = new uint256[](numberOfTokensOwned);

        uint256 currentIndex = 0;
        for (uint256 i = 0; i < ownedPerWallet[msg.sender].length; i++) {
            if (ownerOf(ownedPerWallet[msg.sender][i]) != msg.sender) continue;
            ownedTokenIds[currentIndex] = ownedPerWallet[msg.sender][i];
            currentIndex += 1;
        }

        return ownedTokenIds;
    }

    function getTokenCreatorById(uint256 tokenId) public view returns (address) {
        return _creators[tokenId];
    }

    function getTokensCreatedByMe() public view returns (uint256[] memory) {
        return createdPerWallet[msg.sender];
    }

        // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
