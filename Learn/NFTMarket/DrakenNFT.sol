// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract DrakenNFT is ERC721URIStorage {
    uint256 private _totalSupply;

    constructor() ERC721("DrakenNFT", "DRK") {}

    function mint(address owner, string memory tokenURI) public returns (uint256) {
        uint tokenId = _totalSupply + 1;
        _totalSupply += 1;
        _mint(owner, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return tokenId;
    }
}