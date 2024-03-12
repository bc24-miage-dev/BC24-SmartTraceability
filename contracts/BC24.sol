// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./SupplyChainData.sol";

/// @custom:security-contact Hugo.albert.marques@gmail.com
contract BC24 is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    SupplyChainData
{
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant TOKEN_OWNER_ROLE = keccak256("TOKEN_OWNER_ROLE");

    uint256 private _nextTokenId;

    //emits an event when a new token is created
    event NFTMinted(uint256 indexed _id);

    // emits an event when metadata is changed
    event MetaDataChanged(string _message);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address defaultAdmin,
        address minter,
        address upgrader,
        address tokenOwner
    ) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __ERC1155Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(UPGRADER_ROLE, upgrader);
        _grantRole(TOKEN_OWNER_ROLE, tokenOwner);
    }

    /* Not directly needed at the moment since we need to define it.  */
    modifier onlyTokenOwner(uint256 tokenId) {
        require(
            hasRole(TOKEN_OWNER_ROLE, msg.sender),
            "Caller is not the token owner"
        );
        _;
    }

    function createToken(
        address account
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        uint256 tokenId = _nextTokenId;
        SupplyChainData.createMetaData(tokenId);
        _mint(account, tokenId, 1, "");
        _nextTokenId++;
        emit NFTMinted(tokenId);
        return tokenId;
    }

    /* Adding Metadata stuff */
    function addBreedingInfo(
        uint256 tokenId,
        string memory typeOfAnimal,
        string memory placeOfOrigin,
        string memory gender,
        uint256 weight,
        string memory healthInformation
    ) public onlyRole(MINTER_ROLE) returns (string memory){

        SupplyChainData.setBreederInfo(
            tokenId,
            typeOfAnimal,
            placeOfOrigin,
            gender,
            weight,
            healthInformation
        );
        
        emit MetaDataChanged("Breeding info added successfully.");

        return "Breeding info added successfully.";
    }

    function addRenderingPlantInfo(
        uint256 tokenId,
        string memory countryOfSlaughter,
        uint256 slaughterhouseAccreditationNumber,
        uint256 slaughterDate
    ) public {
        SupplyChainData.setRenderingPlantInfo(
            tokenId,
            countryOfSlaughter,
            slaughterhouseAccreditationNumber,
            slaughterDate
        );

        emit MetaDataChanged("Rendering plant info added successfully.");
    }

    function getMetaData(
        uint256 _tokenId
    ) public view returns (MetaData memory) {
        return SupplyChainData.getSupplyChainData(_tokenId);
    }

    function tester() public pure returns (string memory) {
        return "Hello World";
    }

    /* Destroys a Token and its associated Metadata */
    function destroyToken(
        address account,
        uint256 _tokenId,
        uint256 amount
    ) public returns (string memory) {
        require(
            balanceOf(account, _tokenId) >= amount,
            "There is no such token to destroy."
        );
        _burn(account, _tokenId, amount);
        SupplyChainData.deleteSupplyChainData(_tokenId);
        return "Token has been successfully destroyed";
    }

    /* Function to get the current amount of tokens around. Needed for testing */
    function getTokenIndex() public view returns (uint256) {
        return _nextTokenId;
    }

    /* Automatically created solidity functions */
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
