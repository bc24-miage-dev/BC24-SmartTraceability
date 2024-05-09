pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IManufacturedProductData.sol";
import "./interfaces/IRoleAccess.sol";
import "./interfaces/IOwnerAndCategoryMapper.sol";
import "./interfaces/IAnimalData.sol";
import "./interfaces/ICarcassData.sol";
import "./interfaces/IMeatData.sol";
import "./interfaces/IRecipeData.sol";
import "./libraries/utils.sol";

contract ManufacturedProductData is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    IManufacturedProductData
{
    IRoleAccess private roleAccessInstance;
    IOwnerAndCategoryMapper private ownerAndCategoryMapperInstance;
    IAnimalData private animalDataInstance;
    ICarcassData private carcassDataInstance;
    IMeatData private meatDataInstance;
    IRecipeData private recipeDataInstance;

    mapping(uint256 => IManufacturedProductData.ManufacturedProductInfo)
        private _tokenProductData;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address defaultAdmin,
        address roleAccessAddress,
        address ownerAndCategoryMapperAddress,
        address animalDataAddress,
        address carcassDataAddress,
        address meatDataAddress,
        address recipeDataAddress
    ) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __ERC1155Burnable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        roleAccessInstance = IRoleAccess(roleAccessAddress);
        ownerAndCategoryMapperInstance = IOwnerAndCategoryMapper(
            ownerAndCategoryMapperAddress
        );
        meatDataInstance = IMeatData(meatDataAddress);
        carcassDataInstance = ICarcassData(carcassDataAddress);
        animalDataInstance = IAnimalData(animalDataAddress);
        recipeDataInstance = IRecipeData(recipeDataAddress);
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

    function createManufacturedProductDataFromRecipe(
        uint256 recipeId,
        uint256[] memory meatIds,
        uint256 price
    ) public onlyManufacturerRole onlyTokenOwnerList(meatIds) {
        for (uint256 i = 0; i < meatIds.length; i++) {
            require(
                checkIfMeatCanBeUsedForRecipe(recipeId, meatIds[i]),
                "Meat is not valid for the recipe"
            );
        }
        IRecipeData.RecipeInfo memory recipe = recipeDataInstance.getRecipeData(
            recipeId
        );

        require(
            Utils.compareArrayLength(meatIds.length, recipe.ingredient.length),
            "Meat count does not match recipe"
        );

        uint256 tokenId = createManufacturedProductDataInternally(
            meatIds,
            recipe.recipeName,
            price,
            recipe.description
        );

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
        for (uint256 i = 0; i < recipe.ingredient.length; i++) {
            if (
                Utils.compareStrings(
                    recipe.ingredient[i].animalType,
                    animal.animalType
                ) && Utils.compareStrings(recipe.ingredient[i].part, meat.part)
            ) {
                isPart = true;
                break;
            }
        }
        if (meat.isContaminated) {
            isPart = false;
        }
        return isPart;
    }

    function createManufacturedProductData(
        uint256[] memory meatIds,
        string memory productName,
        uint256 price,
        string memory description
    ) external onlyTokenOwnerList(meatIds) onlyManufacturerRole {
        uint256 tokenId = createManufacturedProductDataInternally(
            meatIds,
            productName,
            price,
            description
        );

        emit NFTMinted(tokenId, msg.sender, "ManufacturedProduct created");
    }

    function createManufacturedProductDataInternally(
        uint256[] memory meatIds,
        string memory productName,
        uint256 price,
        string memory description
    ) internal returns (uint256) {
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

        return tokenId;
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
}
