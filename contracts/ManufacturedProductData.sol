pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IManufacturedProductData.sol";

contract ManufacturedProductData is 
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    IManufacturedProductData 
{
        
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __ERC1155Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    mapping(uint256 => IManufacturedProductData.ManufacturedProductInfo) private _tokenProductData;

    function createManufacturedProduct(uint256 tokenId, uint256[] memory meatIds) external {
        ManufacturedProductInfo storage product = _tokenProductData[tokenId];
        product.meatIds = meatIds;
        product.timingInfo.creationDate = block.timestamp;
        product.category = "ManufacturedProduct";
    }

    function createManufacturedProductAll(
        uint256 tokenId,
        uint256[] memory meatIds,
        string memory productName,
        uint256 price,
        string memory description
    ) external {
        // Créer une nouvelle instance de produit manufacturé
        ManufacturedProductInfo storage product = _tokenProductData[tokenId];

        // Remplir les détails du produit
        product.meatIds = meatIds;
        product.productName = productName;
        product.price = price;
        product.description = description;
        product.timingInfo.creationDate = block.timestamp;
        product.category = "ManufacturedProduct";
    }

    function setManufacturedProductData(
        uint256 tokenId,
        uint256 dateOfManufacturation,
        string memory productName,
        uint256 price,
        string memory description
    ) external {
        ManufacturedProductInfo storage product = _tokenProductData[tokenId];
        product.dateOfManufacturation = dateOfManufacturation;
        product.productName = productName;
        product.timingInfo.lastUpdateDate = block.timestamp;
        product.price = price; 
        product.description = description;
    }

    function getManufacturedProductData(
        uint256 tokenId
    ) external view returns (ManufacturedProductInfo memory) {
        return _tokenProductData[tokenId];
    }

    function supportsInterface(
    bytes4 interfaceId
    )
        public
        view
        override(AccessControlUpgradeable, ERC1155Upgradeable)
        returns (bool)
    {}
    
    function _authorizeUpgrade(address newImplementation) internal virtual override {}
}
