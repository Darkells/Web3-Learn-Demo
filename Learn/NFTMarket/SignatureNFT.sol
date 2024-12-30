// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract SigntureNFT is ERC721 {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
    address public immutable signer;

    mapping(address => bool) public mintedAddress;

    constructor(
        string memory _name,
        string memory _symbol,
        address _signer
    ) ERC721(_name, _symbol) {
        signer = _signer;
    }

    function mint(
        address _account,
        uint256 _tokenId,
        bytes memory _signature
    ) external {
        bytes32 _msgHash = getMessageHash(_account, _tokenId);
        bytes32 _ethSignedMessageHash = _msgHash.toEthSignedMessageHash();
        require(verify(_ethSignedMessageHash, _signature), "Invalid signature");
        require(!mintedAddress[_account], "Already minted!");
        _mint(_account, _tokenId);
        mintedAddress[_account] = true;
    }

    function getMessageHash(
        address _account,
        uint256 _tokenId
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    function verify(
        bytes32 _msgHash,
        bytes memory _signature
    ) public view returns (bool) {
        return _msgHash.toEthSignedMessageHash().recover(_signature) == signer;
    }
}
