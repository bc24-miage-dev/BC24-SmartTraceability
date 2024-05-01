pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IMeatData.sol";
import "./interfaces/IRoleAccess.sol";
import "./interfaces/IOwnerAndCategoryMapper.sol";

contract MeatData is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    IMeatData
{
    IRoleAccess private roleAccessInstance;
    IOwnerAndCategoryMapper private ownerAndCategoryMapperInstance;

    mapping(uint256 => IMeatData.MeatInfo) private _tokenMeatData;

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
    modifier onlyMeatNFT(uint256 tokenId) {
        require(
            ownerAndCategoryMapperInstance.getTokenCategoryType(tokenId) ==
                CategoryTypes.Types.Meat,
            "Token is not an meat NFT"
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

    function createMeatData(
        uint256 carcassId,
        string memory part,
        uint256 weight
    ) external {
        uint256 tokenId = ownerAndCategoryMapperInstance.getNextTokenId();
        _mint(msg.sender, tokenId, 1, "");
        ownerAndCategoryMapperInstance.setOwnerOfToken(tokenId, msg.sender);
        ownerAndCategoryMapperInstance.setTokenCategoryType(
            tokenId,
            CategoryTypes.Types.Meat
        );
        ownerAndCategoryMapperInstance.setNextTokenId(tokenId + 1);

        IMeatData.MeatInfo storage meat = _tokenMeatData[tokenId];
        meat.carcassId = carcassId;
        meat.timingInfo.creationDate = block.timestamp;
        meat.category = "Meat";
        meat.part = part;
        meat.weight = weight;

        emit NFTMinted(tokenId, msg.sender, "MeatNFT created");
    }

    function setMeatData(
        uint256 tokenId,
        string memory agreementNumber,
        string memory countryOfCutting,
        uint256 dateOfCutting,
        string memory part,
        bool isContaminated,
        uint256 weight
    )
        external
        onlyMeatNFT(tokenId)
        onlyManufacturerRole
        onlyTokenOwner(tokenId)
    {
        IMeatData.MeatInfo storage meat = _tokenMeatData[tokenId];
        meat.agreementNumber = agreementNumber;
        meat.countryOfCutting = countryOfCutting;
        meat.dateOfCutting = dateOfCutting;
        meat.part = part;
        meat.timingInfo.lastUpdateDate = block.timestamp;
        meat.isContaminated = isContaminated;
        meat.weight = weight;

        emit MetaDataChanged(tokenId, msg.sender, "Meat info changed.");
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
