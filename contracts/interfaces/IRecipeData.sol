pragma solidity ^0.8.20;

interface IRecipeData{
    struct RecipeInfo {
        string recipeName;
        string description;
        IngredientMeat[] ingredientMeat;
    }

    struct IngredientMeat {
        string part;
        string animalType;
    }

    function createRecipe(
        uint256 recipeId,
        string memory recipeName,
        string memory description,
        string[] memory ingredientMeat,
        string[] memory ingredientPart
    ) external;

    function getRecipeData(
        uint256 recipeId
    ) external view returns (RecipeInfo memory);

    function test() external pure returns (string memory);
}
