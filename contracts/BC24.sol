// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./TransportData.sol";
import "./MeatData.sol";
import "./ManufacturedProductData.sol";

import "./interfaces/IAnimalData.sol";
import "./interfaces/ICarcassData.sol";
import "./interfaces/IRecipeData.sol";

/// @custom:security-contact Hugo.albert.marques@gmail.com
contract BC24 is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    TransportData,
    MeatData,
    ManufacturedProductData
{
    enum CategoryType {
        Animal,
        Carcass,
        Transport,
        Meat,
        ManufacturedProduct
    }

    //general roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // specific roles
    bytes32 public constant BREEDER_ROLE = keccak256("BREEDER_ROLE");
    bytes32 public constant TRANSPORTER_ROLE = keccak256("TRANSPORTER_ROLE");
    bytes32 public constant SLAUGHTER_ROLE = keccak256("SLAUGHTER_ROLE");
    bytes32 public constant MANUFACTURERE_ROLE =
        keccak256("MANUFACTURERE_ROLE");

    // other roles
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant TOKEN_OWNER_ROLE = keccak256("OWNER_ROLE");

    uint256 private _nextTokenId;
    mapping(uint256 => address) private tokenOwners;

    // Add this to your contract

    mapping(uint256 => CategoryType) public tokenCategoryTypes;

    //emits an event when a new token is created
    event NFTMinted(uint256 tokenId, address owner, string message);

    // emits an event when metadata is changed
    event MetaDataChanged(uint256 tokenId, address owner, string message);

    IAnimalData private animalDataInstance;
    ICarcassData private carcassDataInstance;
    IRecipeData private recipeDataInstance;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address defaultAdmin,
        address animalDataAddress,
        address carcassDataAdress,
        address recipeDataAddress
    ) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __ERC1155Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        animalDataInstance = IAnimalData(animalDataAddress);
        carcassDataInstance = ICarcassData(carcassDataAdress);
        recipeDataInstance = IRecipeData(recipeDataAddress);
    }

    /* Not directly needed at the moment since we need to define it.  */
    modifier onlyBreederRole() {
        require(hasRole(BREEDER_ROLE, msg.sender), "Caller is not a breeder");
        _;
    }

    modifier onlyTransporterRole() {
        require(
            hasRole(TRANSPORTER_ROLE, msg.sender),
            "Caller is not a transporter"
        );
        _;
    }
    

    modifier onlySlaughterRole() {
        require(
            hasRole(SLAUGHTER_ROLE, msg.sender),
            "Caller is not a slaughterer"
        );
        _;
    }

    modifier onlyManufacturerRole() {
        require(
            hasRole(MANUFACTURERE_ROLE, msg.sender),
            "Caller is not a slaughterer"
        );
        _;
    }

    modifier onlyMinterRole() {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        _;
    }

    modifier onlyTokenOwner(uint256 tokenId) {
        require(
            msg.sender == tokenOwners[tokenId],
            "Caller does not own this token"
        );
        _;
    }
    modifier onlyTokenOwnerList(uint256[] memory tokenIds) {
    for (uint256 i = 0; i < tokenIds.length; i++) {
        require(
            msg.sender == tokenOwners[tokenIds[i]],
            "Caller does not own one of the tokens"
        );
    }
    _;
    }


    modifier receiverOnlyRole(bytes32 role, address receiver) {
        require(hasRole(role, receiver), "Caller is not valid receiver");
        _;
    }

    function grantRoleToAddress(
        address account,
        string memory role
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (
            keccak256(abi.encodePacked(role)) ==
            keccak256(abi.encodePacked("MINTER_ROLE"))
        ) {
            grantRole(MINTER_ROLE, account);
        } else if (
            keccak256(abi.encodePacked(role)) ==
            keccak256(abi.encodePacked("BREEDER_ROLE"))
        ) {
            grantRole(BREEDER_ROLE, account);
        } else if (
            keccak256(abi.encodePacked(role)) ==
            keccak256(abi.encodePacked("TRANSPORTER_ROLE"))
        ) {
            grantRole(TRANSPORTER_ROLE, account);
        } else if (
            keccak256(abi.encodePacked(role)) ==
            keccak256(abi.encodePacked("SLAUGHTER_ROLE"))
        ) {
            grantRole(SLAUGHTER_ROLE, account);
        } else if (
            keccak256(abi.encodePacked(role)) ==
            keccak256(abi.encodePacked("MANUFACTURERE_ROLE"))
        ) {
            grantRole(MANUFACTURERE_ROLE, account);
        } else {
            revert("Invalid role");
        }
    }

    /* Token Creation functions */

    function createAnimal(
        address account,
        string memory animalType,
        uint256 weight,
        string memory gender
    ) public onlyBreederRole onlyMinterRole returns (uint256) {
        uint256 tokenId = _nextTokenId;
        animalDataInstance.createAnimalData(
            tokenId,
            animalType,
            weight,
            gender
        );
        _mint(account, tokenId, 1, "");
        tokenOwners[tokenId] = msg.sender;
        tokenCategoryTypes[tokenId] = CategoryType.Animal;
        _nextTokenId++;
        emit NFTMinted(tokenId, msg.sender, "AnimalNFT created");
        return tokenId;
    }

    function slaughterAnimal(
        uint256 animalId
    ) public onlySlaughterRole onlyTokenOwner(animalId) returns (uint256) {
        animalDataInstance.killAnimal(animalId);

        uint256 tokenId = _nextTokenId;
        _mint(msg.sender, tokenId, 1, "");
        carcassDataInstance.createCarcassData(tokenId, animalId);
        tokenOwners[tokenId] = msg.sender;
        tokenCategoryTypes[tokenId] = CategoryType.Carcass;
        _nextTokenId++;
        emit NFTMinted(tokenId, msg.sender, "CarcassNFT created");
        return tokenId;
    }

    function createMeat(
        uint256 carcassId
    ) public onlyManufacturerRole onlyTokenOwner(carcassId) returns (uint256) {
        uint256 tokenId = _nextTokenId;
        _mint(msg.sender, tokenId, 1, "");
        uint256 weight = 99; //hardcoded value !!
        MeatData.createMeatData(tokenId, carcassId, weight);
        tokenOwners[tokenId] = msg.sender;
        tokenCategoryTypes[tokenId] = CategoryType.Meat;
        _nextTokenId++;
        emit NFTMinted(tokenId, msg.sender, "MeatNFT created");
        return tokenId;
    }

    function createManufacturedProduct(
        uint256[] memory meatId
    ) public onlyManufacturerRole onlyTokenOwnerList(meatId) returns (uint256) {
        uint256 tokenId = _nextTokenId;
        _mint(msg.sender, tokenId, 1, "");
        ManufacturedProductData.createProductData(tokenId, meatId);
        tokenOwners[tokenId] = msg.sender;
        tokenCategoryTypes[tokenId] = CategoryType.ManufacturedProduct;
        _nextTokenId++;
        emit NFTMinted(tokenId, msg.sender, "ManufacturedProduct created");
        return tokenId;
    }
    /* Token Update functions */

    function updateAnimal(
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
    }

    function updateTransport(
        uint256 tokenId,
        uint256 duration,
        uint256 temperature,
        uint256 humidity,
        bool isContaminated
    )
        public
        onlyTransporterRole
        onlyTokenOwner(tokenId)
        returns (string memory)
    {
        TransportData.setTransportData(
            tokenId,
            duration,
            temperature,
            humidity,
            isContaminated
        );
        emit MetaDataChanged(
            tokenId,
            msg.sender,
            "Transport info changed."
        );
        return "Transport info changed.";
    }

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
        MeatData.setMeatData(
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
        ManufacturedProductData.setManufacturedProductData(
            tokenId,
            dateOfManufacturation,
            productName,
            price,
            description
        );
        emit MetaDataChanged(tokenId, msg.sender, "ManufacturedProduct info changed.");
        return "ManufacturedProduct info changed.";
    }

    /* Token Getter functions */

    function getAnimal(
        uint256 tokenId
    )
        public
        view
        onlyTokenOwner(tokenId)
        returns (IAnimalData.AnimalInfo memory)
    {
        return animalDataInstance.getAnimalData(tokenId);
    }

    function getCarcass(
        uint256 tokenId
    )
        public
        view
        onlyTokenOwner(tokenId)
        returns (ICarcassData.CarcassInfo memory)
    {
        return carcassDataInstance.getCarcassData(tokenId);
    }

    function getTransport(
        uint256 tokenId
    ) public view onlyTokenOwner(tokenId) returns (TransportInfo memory) {
        return TransportData.getTransportData(tokenId);
    }

    function getMeat(
        uint256 tokenId
    ) public view onlyTokenOwner(tokenId) returns (MeatInfo memory) {
        return MeatData.getMeatData(tokenId);
    }

    function getManufacturedProduct(
        uint256 tokenId
    ) public view onlyTokenOwner(tokenId) returns (ManufacturedProductInfo memory) {
        return ManufacturedProductData.getManufacturedProductData(tokenId);
    }

    function getRecipe(uint256 tokenId
    ) public view onlyTokenOwner(tokenId) returns (IRecipeData.RecipeInfo memory){  
        return recipeDataInstance.getRecipeData(tokenId);
    }

    /* Token Transfer functions */

    function transferAnimalToTransporter(
        uint256 tokenId,
        address transporter
    )
        public
        onlyBreederRole
        onlyTokenOwner(tokenId)
        receiverOnlyRole(TRANSPORTER_ROLE, transporter)
    {
        safeTransferFrom(msg.sender, transporter, tokenId, 1, "");
        tokenOwners[tokenId] = transporter;
        TransportData.createTransportData(tokenId);
    }

    function transferAnimalToSlaugtherer(
        uint256 tokenId,
        address slaughterer
    )
        public
        onlyTransporterRole
        onlyTokenOwner(tokenId)
        receiverOnlyRole(SLAUGHTER_ROLE, slaughterer)
    {
        safeTransferFrom(msg.sender, slaughterer, tokenId, 1, "");
        tokenOwners[tokenId] = slaughterer;
    }

    function transferCarcassToTransporter(
        uint256 tokenId,
        address transporter
    )
        public
        onlySlaughterRole
        onlyTokenOwner(tokenId)
        receiverOnlyRole(TRANSPORTER_ROLE, transporter)
    {
        safeTransferFrom(msg.sender, transporter, tokenId, 1, "");
        tokenOwners[tokenId] = transporter;
    }

    function transferCarcassToManufacturer(
        uint256 tokenId,
        address manufacturer
    )
        public
        onlyTransporterRole
        onlyTokenOwner(tokenId)
        receiverOnlyRole(MANUFACTURERE_ROLE, manufacturer)
    {
        safeTransferFrom(msg.sender, manufacturer, tokenId, 1, "");
        tokenOwners[tokenId] = manufacturer;
    }

    function tester() public pure returns (string memory) {
        return "Hello World";
    }

    /* Destroys a Token and its associated Metadata */
    function destroyToken(
        address account,
        uint256 _tokenId,
        uint256 amount
    ) public returns (string memory) {
        require(
            balanceOf(account, _tokenId) >= amount,
            "There is no such token to destroy."
        );
        _burn(account, _tokenId, amount);
        //SupplyChainData.deleteSupplyChainData(_tokenId);
        return "Token has been successfully destroyed";
    }

    /* Function to get the current amount of tokens around. Needed for testing */
    function getTokenIndex() public view returns (uint256) {
        return _nextTokenId;
    }

    /* Automatically created solidity functions */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

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

    function ownerOf(uint256 tokenId) public view returns (address) {
        return tokenOwners[tokenId];
    }

    function getTokensOfOwner() public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_nextTokenId);
        uint256 counter = 0;
        for (uint256 i = 0; i < _nextTokenId; i++) {
            if (tokenOwners[i] == msg.sender) {
                result[counter] = i;
                counter++;
            }
        }
        // resize the array
        uint256[] memory finalResult = new uint256[](counter);
        for (uint256 i = 0; i < counter; i++) {
            finalResult[i] = result[i];
        }
        return finalResult;
    }

    function getTokenDataType(uint256 tokenId) public view returns (CategoryType) {
        return tokenCategoryTypes[tokenId];
    }

    function getTokensByDataType(
        string memory _dataType
    ) public view returns (uint256[] memory) {
        CategoryType dataType = stringToDataType(_dataType);
        uint256[] memory result = new uint256[](_nextTokenId);
        uint256 counter = 0;
        for (uint256 i = 0; i < _nextTokenId; i++) {
            if (tokenCategoryTypes[i] == dataType) {
                result[counter] = i;
                counter++;
            }
        }
        // resize the array
        uint256[] memory finalResult = new uint256[](counter);
        for (uint256 i = 0; i < counter; i++) {
            finalResult[i] = result[i];
        }
        return finalResult;
    }

    function stringToDataType(
        string memory dataType
    ) public pure returns (CategoryType) {
        if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("Animal")))
        ) {
            return CategoryType.Animal;
        } else if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("Carcass")))
        ) {
            return CategoryType.Carcass;
        } else if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("Transport")))
        ) {
            return CategoryType.Transport;
        } else if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("Meat")))
        ) {
            return CategoryType.Meat;
        } else if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("ManufacturedProduct")))
        ) {
            return CategoryType.ManufacturedProduct;
        } else {
            revert("Invalid data type");
        }
    }
}
