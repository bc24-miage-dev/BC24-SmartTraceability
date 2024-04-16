pragma solidity ^0.8.0;
import "./BaseData.sol";

abstract contract RecipeData is BaseData {
    struct RecipeInfo {
        string recipeName;
        string description;
        IngredientOther[] ingredientsOther; // Liste des ingrédients autres nécessaires à la recette avec leurs quantités 
        IngredientMeat[] ingredientMeat; // Liste des ingrédients de viande nécessaires à la recette
    }
    
    struct IngredientOther {
        string name;
        uint256 weight;
    }

    struct IngredientMeat {
        string part;
        string animalType;
        uint256 weight;
    }

    mapping(uint256 => RecipeInfo) private _tokenRecipeData;
    
    function createRecipe(
        uint256 recipeId,
        string memory recipeName,
        string memory description,
        IngredientOther[] memory ingredientsOther,
        IngredientMeat[] memory ingredientMeat
    ) internal {
        RecipeInfo storage recipe = _tokenRecipeData[recipeId];
        recipe.recipeName = recipeName;
        recipe.description = description;
        recipe.ingredientsOther = ingredientsOther;
        recipe.ingredientMeat = ingredientMeat;
    }

    function getRecipeData(uint256 recipeId) public view returns (RecipeInfo memory) {
        return _tokenRecipeData[recipeId];
    }

    function setRecipeName(uint256 recipeId, string memory newName) internal {
        _tokenRecipeData[recipeId].recipeName = newName;
    }

    function setRecipeDescription(uint256 recipeId, string memory newDescription) internal {
        _tokenRecipeData[recipeId].description = newDescription;
    }

}
