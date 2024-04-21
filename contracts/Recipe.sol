pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IRecipeData.sol";

contract RecipeData is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    IRecipeData
{
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

    mapping(uint256 => IRecipeData.RecipeInfo) private _tokenRecipeData;

    function createRecipeData(
        uint256 recipeId,
        string memory recipeName,
        string memory description,
        string[] memory ingredientMeat,
        string[] memory ingredientPart
    ) external {
        require(
            ingredientMeat.length == ingredientPart.length,
            "ingredientMeat and ingredientPart must have the same length"
        );
        IRecipeData.RecipeInfo storage recipe = _tokenRecipeData[recipeId];
        recipe.recipeName = recipeName;
        recipe.description = description;

        for (uint i = 0; i < ingredientMeat.length; i++) {
            IRecipeData.IngredientMeat memory ingredient = IRecipeData
                .IngredientMeat({
                    part: ingredientPart[i],
                    animalType: ingredientMeat[i]
                });

            recipe.ingredientMeat.push(ingredient);
        }
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

    function test() external pure override returns (string memory) {}
}
