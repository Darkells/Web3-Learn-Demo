// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFMarket is IERC721Receiver {
    mapping(uint => uint) public tokenIdToPrice;

    address public immutable token;

    address public immutable nft;

    constructor(address _token, address _nft) {
        token = _token;
        nft = _nft;
    }


    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function list(uint _tokenId, uint _price) external {
        IERC721(nft).safeTransferFrom(msg.sender, address(this), _tokenId, "");
        tokenIdToPrice[_tokenId] += _price;
    }

    function buy(uint _tokenId, uint amount) external {
        require(amount >= tokenIdToPrice[_tokenId], "");
        require(
            IERC721(nft).ownerOf(_tokenId) == address(this),
            "already sold"
        );
        IERC20(token).transferFrom(
            msg.sender,
            address(this),
            tokenIdToPrice[_tokenId]
        );
        IERC721(nft).transferFrom(address(this), msg.sender, _tokenId);
    }
}
