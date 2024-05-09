pragma solidity ^0.8.20;

interface IRecipeData {
    struct RecipeInfo {
        string recipeName;
        string description;
        Ingredient[] ingredient;
    }

    struct Ingredient {
        string part;
        string animalType;
        uint256 weight;
    }

    function createRecipeData(
        string memory recipeName,
        string memory description,
        string[] memory ingredientMeat,
        string[] memory ingredientPart,
        uint256[] memory ingredientWeight
    ) external;

    function setRecipeData(
        uint256 tokenId,
        string memory recipeName,
        string memory description,
        string[] memory ingredientMeat,
        string[] memory ingredientPart,
        uint256[] memory ingredientWeight
    ) external;

    function getRecipeData(
        uint256 recipeId
    ) external view returns (RecipeInfo memory);

}
