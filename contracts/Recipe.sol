pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IRecipeData.sol";
import "./interfaces/IRoleAccess.sol";
import "./interfaces/IOwnerAndCategoryMapper.sol";

contract RecipeData is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    IRecipeData
{
    IRoleAccess private roleAccessInstance;
    IOwnerAndCategoryMapper private ownerAndCategoryMapperInstance;

    mapping(uint256 => IRecipeData.RecipeInfo) private _tokenRecipeData;

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
    modifier onlyReipeNFT(uint256 tokenId) {
        require(
            ownerAndCategoryMapperInstance.getTokenCategoryType(tokenId) ==
                CategoryTypes.Types.Recipe,
            "Token is not an recipe NFT"
        );
        _;
    }

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

    function createRecipeData(
        string memory recipeName,
        string memory description,
        string[] memory ingredientMeat,
        string[] memory ingredientPart,
        uint256[] memory ingredientWeight
    ) external onlyManufacturerRole {
        require(
            ingredientMeat.length == ingredientPart.length &&
                ingredientMeat.length == ingredientWeight.length,
            "ingredientMeat, ingredientPart and ingredientWeight must have the same length"
        );

        uint256 tokenId = ownerAndCategoryMapperInstance.getNextTokenId();
        _mint(msg.sender, tokenId, 1, "");
        ownerAndCategoryMapperInstance.setOwnerOfToken(tokenId, msg.sender);
        ownerAndCategoryMapperInstance.setTokenCategoryType(
            tokenId,
            CategoryTypes.Types.Recipe
        );
        ownerAndCategoryMapperInstance.setNextTokenId(tokenId + 1);

        IRecipeData.RecipeInfo storage recipe = _tokenRecipeData[tokenId];
        recipe.recipeName = recipeName;
        recipe.description = description;

        for (uint i = 0; i < ingredientMeat.length; i++) {
            IRecipeData.Ingredient memory ingredient = IRecipeData.Ingredient({
                part: ingredientPart[i],
                animalType: ingredientMeat[i],
                weight: ingredientWeight[i]
            });
            recipe.ingredient.push(ingredient);
        }

        emit NFTMinted(tokenId, msg.sender, "RecipeNFT created");
    }

    function setRecipeData(
        uint256 tokenId,
        string memory recipeName,
        string memory description,
        string[] memory ingredientMeat,
        string[] memory ingredientPart,
        uint256[] memory ingredientWeight
    ) external onlyReipeNFT(tokenId) onlyTokenOwner(tokenId) {
        require(
            ingredientMeat.length == ingredientPart.length &&
                ingredientMeat.length == ingredientWeight.length,
            "ingredientMeat, ingredientPart and ingredientWeight must have the same length"
        );

        IRecipeData.RecipeInfo storage recipe = _tokenRecipeData[tokenId];
        recipe.recipeName = recipeName;
        recipe.description = description;

        for (uint i = 0; i < ingredientMeat.length; i++) {
            IRecipeData.Ingredient memory ingredient = IRecipeData.Ingredient({
                part: ingredientPart[i],
                animalType: ingredientMeat[i],
                weight: ingredientWeight[i]
            });

            recipe.ingredient.push(ingredient);
        }

        emit MetaDataChanged(tokenId, msg.sender, "Recipe info changed.");
    }

    function getRecipeData(
        uint256 recipeId
    ) public view returns (RecipeInfo memory) {
        return _tokenRecipeData[recipeId];
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
