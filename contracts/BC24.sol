// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @custom:security-contact Hugo.albert.marques@gmail.com
contract BC24 is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    struct TokenMetadata {
        string jsonString; // JSON-like metadata
    }

    uint256 private _nextTokenId;

    mapping(uint256 => TokenMetadata) private _tokenMetadata;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _nextTokenId = 1; // Initialize the next token ID to 1
        _disableInitializers();
    }

    function initialize(
        address defaultAdmin,
        address minter,
        address upgrader
    ) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __ERC1155Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(UPGRADER_ROLE, upgrader);
    }

    function createToken(
        address account,
        string memory jsonData
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        uint256 tokenId = _nextTokenId;
        _tokenMetadata[tokenId] = TokenMetadata(jsonData);
        _mint(account, tokenId, 1, "");
        _nextTokenId++;
        return tokenId;
    }

    function destroyToken(
        address account,
        uint256 tokenId,
        uint256 amount
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (string memory) {
        require(
            balanceOf(account, tokenId) >= amount,
            "There is no such token to destroy."
        );
        _burn(account, tokenId, amount);
        delete _tokenMetadata[tokenId];
        return "Token has been successfully destroyed";
    }

    function getMetadata(
        uint256 tokenId
    ) external view returns (string memory) {
        TokenMetadata memory metadata = _tokenMetadata[tokenId];
        return metadata.jsonString;
    }

    function setMetadata(
        uint256 tokenId,
        string memory jsonString
    ) public returns (string memory) {
        _tokenMetadata[tokenId] = TokenMetadata(jsonString);
        return "Metadata has been successfully set";
    }

    // solidity functions

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
