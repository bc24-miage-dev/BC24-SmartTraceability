pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IMeatData.sol";


contract MeatData is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    IMeatData
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

    mapping(uint256 => IMeatData.MeatInfo) private _tokenMeatData;

    function createMeatData(
        uint256 tokenId,
        uint256 carcassId,
        uint256 weight
    ) external {
        IMeatData.MeatInfo storage meat = _tokenMeatData[tokenId];
        meat.carcassId = carcassId;
        meat.timingInfo.creationDate = block.timestamp;
        meat.category = "Meat";
        meat.weight = weight; // Assigner le poids du morceau de viande
    }

    function setMeatData(
        uint256 tokenId,
        string memory agreementNumber,
        string memory countryOfCutting,
        uint256 dateOfCutting,
        string memory part,
        bool isContaminated,
        uint256 weight // Ajouter le poids en tant que paramètre
    ) external {
        IMeatData.MeatInfo storage meat = _tokenMeatData[tokenId];
        meat.agreementNumber = agreementNumber;
        meat.countryOfCutting = countryOfCutting;
        meat.dateOfCutting = dateOfCutting;
        meat.part = part;
        meat.timingInfo.lastUpdateDate = block.timestamp;
        meat.isContaminated = isContaminated;
        meat.weight = weight; // Assigner le poids du morceau de viande
    }

    function getMeatData(
        uint256 tokenId
    ) public view returns (MeatInfo memory) {
        return _tokenMeatData[tokenId];
    }

    // Fonction pour vérifier si la catégorie de viande correspond à celle requise
    function checkMeatCategory(
        uint256 tokenId,
        string memory requiredCategory
    ) public view returns (bool) {
        return
            keccak256(abi.encodePacked(_tokenMeatData[tokenId].category)) ==
            keccak256(abi.encodePacked(requiredCategory));
    }

    // Fonction pour vérifier si le poids de la viande est suffisant
    function checkMeatWeight(
        uint256 tokenId,
        uint256 requiredWeight
    ) public view returns (bool) {
        return _tokenMeatData[tokenId].weight >= requiredWeight;
    }

    // Fonction pour vérifier la partie de la viande
    function checkMeatPart(
        uint256 tokenId,
        string memory requiredPart
    ) public view returns (bool) {
        return
            keccak256(abi.encodePacked(_tokenMeatData[tokenId].part)) ==
            keccak256(abi.encodePacked(requiredPart));
    }

    // Fonction pour mettre à jour le poids de la viande
    function updateMeatWeight(uint256 tokenId, uint256 newWeight) external {
        _tokenMeatData[tokenId].weight = newWeight;
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
