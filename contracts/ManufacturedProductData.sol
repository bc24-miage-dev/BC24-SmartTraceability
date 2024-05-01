pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IManufacturedProductData.sol";
import "./interfaces/IRoleAccess.sol";
import "./interfaces/IOwnerAndCategoryMapper.sol";
import "./libraries/utils.sol";

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


     modifier onlyTokenOwnerList(uint256[] memory tokenIds) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                msg.sender ==
                    ownerAndCategoryMapperInstance.getOwnerOfToken(tokenIds[i]),
                "Caller does not own all of the tokens"
            );
        }
        _;
    }

    /*     function createManufacturedProductDataFromRecipe (
        uint256 recipeId,
        uint256[] memory meatId,
        string memory productName,
        uint256 price,
        string memory description
    ) public onlyManufacturerRole onlyTokenOwnerList(meatId) returns (uint256) {
        uint256 tokenId = roleAccessInstance.getNextTokenId();

        if (recipeId == 0) {
            //create a new product
            _mint(msg.sender, tokenId, 1, "");
            manufacturedProductDataInstance.createManufacturedProductData(
                tokenId,
                meatId,
                productName,
                price,
                description
            );
        } else {
            for (uint256 i = 0; i < meatId.length; i++) {
                require(
                    checkIfMeatCanBeUsedForRecipe(recipeId, meatId[i]),
                    "Meat is not valid for the recipe"
                );
            }
            IRecipeData.RecipeInfo memory recipe = recipeDataInstance
                .getRecipeData(recipeId);

            require(
                Utils.compareArrayLength(
                    meatId.length,
                    recipe.ingredientMeat.length
                ),
                "Meat count does not match recipe"
            );

            _mint(msg.sender, tokenId, 1, "");

            manufacturedProductDataInstance.createManufacturedProductData(
                tokenId,
                meatId,
                recipe.recipeName,
                price,
                recipe.recipeName
            );
        }

        roleAccessInstance.setOwnerOfToken(tokenId, msg.sender);
        roleAccessInstance.setTokenCategoryType(
            tokenId,
            CategoryTypes.Types.ManufacturedProduct
        );
        roleAccessInstance.setNextTokenId(tokenId + 1);
        emit NFTMinted(tokenId, msg.sender, "ManufacturedProduct created");
    }

    function checkIfMeatCanBeUsedForRecipe(
        uint256 recipeId,
        uint256 meatId
    ) public view returns (bool) {
        IMeatData.MeatInfo memory meat = meatDataInstance.getMeatData(meatId);
        ICarcassData.CarcassInfo memory carcass = carcassDataInstance
            .getCarcassData(meat.carcassId);
        IAnimalData.AnimalInfo memory animal = animalDataInstance.getAnimalData(
            carcass.animalId
        );
        IRecipeData.RecipeInfo memory recipe = recipeDataInstance.getRecipeData(
            recipeId
        );

        bool isPart = false;
        for (uint256 i = 0; i < recipe.ingredientMeat.length; i++) {
            if (
                Utils.compareStrings(
                    recipe.ingredientMeat[i].animalType,
                    animal.animalType
                ) &&
                Utils.compareStrings(recipe.ingredientMeat[i].part, meat.part)
            ) {
                isPart = true;
                break;
            }
        }
        if (meat.isContaminated) {
            isPart = false;
        }
        return isPart;
    } */

    function createManufacturedProductData(
        uint256[] memory meatIds,
        string memory productName,
        uint256 price,
        string memory description
    ) external onlyTokenOwnerList(meatIds) onlyManufacturerRole {
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
