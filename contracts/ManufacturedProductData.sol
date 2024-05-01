pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IManufacturedProductData.sol";
import "./interfaces/IRoleAccess.sol";
import "./interfaces/IOwnerAndCategoryMapper.sol";

contract ManufacturedProductData is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    IManufacturedProductData
{
    IRoleAccess private roleAccessInstance;
    IOwnerAndCategoryMapper private ownerAndCategoryMapperInstance;

    mapping(uint256 => IManufacturedProductData.ManufacturedProductInfo)
        private _tokenProductData;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address defaultAdmin,
        address roleAccessAddress,
        address ownerAndCategoryMapperAddress
    ) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __ERC1155Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        roleAccessInstance = IRoleAccess(roleAccessAddress);
        ownerAndCategoryMapperInstance = IOwnerAndCategoryMapper(
            ownerAndCategoryMapperAddress
        );
    }

    /* Event Emitters */
    event NFTMinted(uint256 tokenId, address owner, string message);
    event MetaDataChanged(uint256 tokenId, address owner, string message);

    /* Access controllers */
    modifier onlyTokenOwner(uint256 tokenId) {
        require(
            ownerAndCategoryMapperInstance.getOwnerOfToken(tokenId) ==
                msg.sender,
            "Caller is not the owner of the token"
        );
        _;
    }

    modifier onlyManufacturerRole() {
        require(
            roleAccessInstance.onlyManufacturerRole(msg.sender),
            "Caller is not a manufacturer"
        );
        _;
    }

    modifier onlyManufacturedProductNFT(uint256 tokenId) {
        require(
            ownerAndCategoryMapperInstance.getTokenCategoryType(tokenId) ==
                CategoryTypes.Types.ManufacturedProduct,
            "Token is not a manufactured product NFT"
        );
        _;
    }

    modifier onlyAllTokenOwner(uint256[] memory tokenIds) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                ownerAndCategoryMapperInstance.getOwnerOfToken(tokenIds[i]) ==
                    msg.sender,
                "Caller is not the owner of the token"
            );
        }
        _;
    }

    function createManufacturedProductData(
        uint256[] memory meatIds,
        string memory productName,
        uint256 price,
        string memory description
    ) external onlyAllTokenOwner(meatIds) onlyManufacturerRole {
        uint256 tokenId = ownerAndCategoryMapperInstance.getNextTokenId();
        _mint(msg.sender, tokenId, 1, "");
        ownerAndCategoryMapperInstance.setOwnerOfToken(tokenId, msg.sender);
        ownerAndCategoryMapperInstance.setTokenCategoryType(
            tokenId,
            CategoryTypes.Types.ManufacturedProduct
        );
        ownerAndCategoryMapperInstance.setNextTokenId(tokenId + 1);

        ManufacturedProductInfo storage product = _tokenProductData[tokenId];

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

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override {}
}
