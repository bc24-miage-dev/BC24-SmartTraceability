// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./interfaces/IAnimalData.sol";
import "./interfaces/ICarcassData.sol";
import "./interfaces/IRecipeData.sol";
import "./interfaces/IMeatData.sol";
import "./interfaces/ITransportData.sol";
import "./interfaces/IManufacturedProductData.sol";
import "./interfaces/IRoleAccess.sol";
import "./interfaces/IOwnerAndCategoryMapper.sol";

import "./libraries/categoryTypes.sol";
import "./libraries/RoleAccessUtils.sol";
import "./libraries/utils.sol";

/// @custom:security-contact Hugo.albert.marques@gmail.com
contract BC24 is
    Initializable,
    ERC1155Upgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    AccessControlUpgradeable
{
    //emits an event when a new token is created
    event NFTMinted(uint256 tokenId, address owner, string message);

    // emits an event when metadata is changed
    event MetaDataChanged(uint256 tokenId, address owner, string message);

    IAnimalData private animalDataInstance;
    ICarcassData private carcassDataInstance;
    IRecipeData private recipeDataInstance;
    IMeatData private meatDataInstance;
    ITransportData private transportDataInstance;
    IManufacturedProductData private manufacturedProductDataInstance;
    IRoleAccess private roleAccessInstance;
    IOwnerAndCategoryMapper private ownerAndCategoryMapperInstance;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address defaultAdmin,
        address animalDataAddress,
        address carcassDataAdress,
        address recipeDataAddress,
        address meatDataAddress,
        address transportDataAddress,
        address manufacturedProductDataAdress,
        address roleAccessAddress,
        address ownerAndCategoryMapperAddress
    ) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __ERC1155Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        animalDataInstance = IAnimalData(animalDataAddress);
        carcassDataInstance = ICarcassData(carcassDataAdress);
        recipeDataInstance = IRecipeData(recipeDataAddress);
        meatDataInstance = IMeatData(meatDataAddress);
        transportDataInstance = ITransportData(transportDataAddress);
        manufacturedProductDataInstance = IManufacturedProductData(
            manufacturedProductDataAdress
        );
        roleAccessInstance = IRoleAccess(roleAccessAddress);
        ownerAndCategoryMapperInstance = IOwnerAndCategoryMapper(
            ownerAndCategoryMapperAddress
        );
    }

    /* Not directly needed at the moment since we need to define it.  */

    modifier onlyBreederRole() {
        require(
            hasRole(RoleAccessUtils.BREEDER_ROLE, msg.sender),
            "Caller is not a breeder"
        );
        _;
    }

    modifier onlyTransporterRole() {
        require(
            hasRole(RoleAccessUtils.TRANSPORTER_ROLE, msg.sender),
            "Caller is not a transporter"
        );
        _;
    }

    modifier onlySlaughterRole() {
        require(
            hasRole(RoleAccessUtils.SLAUGHTER_ROLE, msg.sender),
            "Caller is not a slaughterer"
        );
        _;
    }

    modifier onlyManufacturerRole() {
        require(
            hasRole(RoleAccessUtils.MANUFACTURERE_ROLE, msg.sender),
            "Caller is not a slaughterer"
        );
        _;
    }

    modifier onlyMinterRole() {
        require(
            hasRole(RoleAccessUtils.MINTER_ROLE, msg.sender),
            "Caller is not a minter"
        );
        _;
    }

    modifier onlyTokenOwner(uint256 tokenId) {
        require(
            msg.sender ==
                ownerAndCategoryMapperInstance.getOwnerOfToken(tokenId),
            "Caller does not own this token"
        );
        _;
    }
    modifier onlyTokenOwnerList(uint256[] memory tokenIds) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                msg.sender ==
                    ownerAndCategoryMapperInstance.getOwnerOfToken(tokenIds[i]),
                "Caller does not own one of the tokens"
            );
        }
        _;
    }

    function grantRoleToAddress(
        address account,
        string memory role
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        roleAccessInstance.grantRoleToAddress(account, role);
    }

    /* Token Creation functions */

    function slaughterAnimal(
        uint256 animalId
    ) public onlySlaughterRole onlyTokenOwner(animalId) returns (uint256) {
        animalDataInstance.killAnimal(animalId);

        uint256 tokenId = ownerAndCategoryMapperInstance.getNextTokenId();
        _mint(msg.sender, tokenId, 1, "");
        //carcassDataInstance.createCarcassData(tokenId, animalId);
        ownerAndCategoryMapperInstance.setOwnerOfToken(tokenId, msg.sender);
        ownerAndCategoryMapperInstance.setTokenCategoryType(
            tokenId,
            CategoryTypes.Types.Carcass
        );
        ownerAndCategoryMapperInstance.setNextTokenId(tokenId + 1);
        emit NFTMinted(tokenId, msg.sender, "CarcassNFT created");
        return tokenId;
    }

    /* 
    function createMeat(
        uint256 carcassId
    ) public onlyManufacturerRole onlyTokenOwner(carcassId) returns (uint256) {
        uint256 tokenId = ownerAndCategoryMapperInstance.getNextTokenId();
        _mint(msg.sender, tokenId, 1, "");
        uint256 weight = 99; //hardcoded value !!
        meatDataInstance.createMeatData(tokenId, carcassId, weight);
        roleAccessInstance.setOwnerOfToken(tokenId, msg.sender);
        roleAccessInstance.setTokenCategoryType(
            tokenId,
            CategoryTypes.Types.Meat
        );

        roleAccessInstance.setNextTokenId(tokenId + 1);
        emit NFTMinted(tokenId, msg.sender, "MeatNFT created");
        return tokenId;
    }

    function createManufacturedProductData(
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
        return tokenId;
    }

    function createRecipe(
        string memory recipeName,
        string memory description,
        string[] memory ingredientMeat,
        string[] memory ingredientPart
    ) public onlyManufacturerRole returns (uint256) {
        uint256 tokenId = roleAccessInstance.getNextTokenId();
        _mint(msg.sender, tokenId, 1, "");
        recipeDataInstance.createRecipeData(
            tokenId,
            recipeName,
            description,
            ingredientMeat,
            ingredientPart
        );
        roleAccessInstance.setOwnerOfToken(tokenId, msg.sender);
        roleAccessInstance.setTokenCategoryType(
            tokenId,
            CategoryTypes.Types.Recipe
        );
        roleAccessInstance.setNextTokenId(tokenId + 1);
        emit NFTMinted(tokenId, msg.sender, "Recipe created");
        return tokenId;
    } */

    /* Token Update functions */

    /* function updateAnimal(
        uint256 tokenId,
        string memory placeOfOrigin,
        uint256 dateOfBirth,
        string memory gender,
        uint256 weight,
        string[] memory sicknessList,
        string[] memory vaccinationList,
        string[] memory foodList,
        bool isContaminated
    ) public onlyBreederRole onlyTokenOwner(tokenId) returns (string memory) {
        animalDataInstance.setAnimalData(
            tokenId,
            placeOfOrigin,
            dateOfBirth,
            gender,
            weight,
            sicknessList,
            vaccinationList,
            foodList,
            isContaminated
        );

        emit MetaDataChanged(tokenId, msg.sender, "Breeding info changed.");

        return "Breeding info changed.";
    } */

    /*  

    function updateCarcass(
        uint256 tokenId,
        string memory agreementNumber,
        string memory countryOfSlaughter,
        uint256 dateOfSlaughter,
        uint256 carcassWeight,
        bool isContaminated
    ) public onlySlaughterRole onlyTokenOwner(tokenId) returns (string memory) {
        carcassDataInstance.setCarcassData(
            tokenId,
            agreementNumber,
            countryOfSlaughter,
            dateOfSlaughter,
            carcassWeight,
            isContaminated
        );

        emit MetaDataChanged(tokenId, msg.sender, "Carcass info changed.");

        return "Carcas info changed.";
    }

    function updateMeat(
        uint256 tokenId,
        string memory agreementNumber,
        string memory countryOfCutting,
        uint256 dateOfCutting,
        string memory part,
        bool isContaminated,
        uint weight
    )
        public
        onlyManufacturerRole
        onlyTokenOwner(tokenId)
        returns (string memory)
    {
        meatDataInstance.setMeatData(
            tokenId,
            agreementNumber,
            countryOfCutting,
            dateOfCutting,
            part,
            isContaminated,
            weight
        );
        emit MetaDataChanged(tokenId, msg.sender, "Meat info changed.");
        return "Meat info changed.";
    }

    function updateManufacturedProduct(
        uint256 tokenId,
        uint256 dateOfManufacturation,
        string memory productName,
        uint256 price,
        string memory description
    )
        public
        onlyManufacturerRole
        onlyTokenOwner(tokenId)
        returns (string memory)
    {
        manufacturedProductDataInstance.setManufacturedProductData(
            tokenId,
            dateOfManufacturation,
            productName,
            price,
            description
        );
        emit MetaDataChanged(
            tokenId,
            msg.sender,
            "ManufacturedProduct info changed."
        );
        return "ManufacturedProduct info changed.";
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

    /* Token Getter functions */


    function getMeat(
        uint256 tokenId
    ) public view returns (IMeatData.MeatInfo memory) {
        return meatDataInstance.getMeatData(tokenId);
    }

    function getManufacturedProduct(
        uint256 tokenId
    )
        public
        view
        returns (IManufacturedProductData.ManufacturedProductInfo memory)
    {
        return
            manufacturedProductDataInstance.getManufacturedProductData(tokenId);
    }

    function getRecipe(
        uint256 tokenId
    ) public view returns (IRecipeData.RecipeInfo memory) {
        return recipeDataInstance.getRecipeData(tokenId);
    }

    /* Token Transfer functions */

    function transferToken(
        uint256 tokenId,
        address receiver
    ) public onlyTokenOwner(tokenId) {
        safeTransferFrom(msg.sender, receiver, tokenId, 1, "");
        ownerAndCategoryMapperInstance.setOwnerOfToken(tokenId, receiver);
        // TODO: Handle transporter get token vs give token
        // transportDataInstance.createTransportData(tokenId);
    }

    /* Automatically created solidity functions */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(RoleAccessUtils.UPGRADER_ROLE) {}

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

    function getTokensOfOwner() public view returns (uint256[] memory) {
        return ownerAndCategoryMapperInstance.getTokensOfOwner(msg.sender);
    }

    /*   function ownerOf(uint256 tokenId) public view returns (address) {
        return tokenDataInstance.getOwnerOfToken(tokenId);
    }

    

    function getTokenDataType(
        uint256 tokenId
    ) public view returns (CategoryTypes.Types) {
        return tokenDataInstance.getTokenCategoryType(tokenId);
    }

    function getTokensByDataType(
        string memory _dataType
    ) public view returns (uint256[] memory) {
        return tokenDataInstance.getTokensOfCategoryType(_dataType);
    } */
}
