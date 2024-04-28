pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/ICarcassData.sol";
import "./interfaces/IRoleAccess.sol";
import "./interfaces/IAnimalData.sol";
import "./interfaces/IOwnerAndCategoryMapper.sol";

contract CarcassData is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    ICarcassData
{
    IRoleAccess private roleAccessInstance;
    IAnimalData private animalDataInstance;
    IOwnerAndCategoryMapper private ownerAndCategoryMapperInstance;

    //emits an event when a new token is created
    event NFTMinted(uint256 tokenId, address owner, string message);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address defaultAdmin,
        address roleAccessAddress,
        address animalDataAddress,
        address ownerAndCategoryMapperAddress
    ) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __ERC1155Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        roleAccessInstance = IRoleAccess(roleAccessAddress);
        animalDataInstance = IAnimalData(animalDataAddress);
        ownerAndCategoryMapperInstance = IOwnerAndCategoryMapper(
            ownerAndCategoryMapperAddress
        );
    }

    mapping(uint256 => ICarcassData.CarcassInfo) private _tokenCarcassData;

    function createCarcassData(uint256 animalId) external {
        uint256 tokenId = ownerAndCategoryMapperInstance.getNextTokenId();
        _mint(msg.sender, tokenId, 1, "");
        ownerAndCategoryMapperInstance.setOwnerOfToken(tokenId, msg.sender);
        ownerAndCategoryMapperInstance.setTokenCategoryType(
            tokenId,
            CategoryTypes.Types.Carcass
        );
        ownerAndCategoryMapperInstance.setNextTokenId(tokenId + 1);

        CarcassInfo storage carcass = _tokenCarcassData[tokenId];
        carcass.timingInfo.creationDate = block.timestamp;
        carcass.animalId = animalId;
        carcass.category = "Carcass";

        emit NFTMinted(tokenId, msg.sender, "CarcassNFT created");
    }

    function setCarcassData(
        uint256 tokenId,
        string memory agreementNumber,
        string memory countryOfSlaughter,
        uint256 dateOfSlaughter,
        uint256 carcassWeight,
        bool isContaminated
    ) external /* onlySlaugthere */ {
        CarcassInfo storage carcass = _tokenCarcassData[tokenId];
        carcass.agreementNumber = agreementNumber;
        carcass.countryOfSlaughter = countryOfSlaughter;
        carcass.dateOfSlaughter = dateOfSlaughter;
        carcass.carcassWeight = carcassWeight;
        carcass.isContaminated = isContaminated;
        carcass.timingInfo.lastUpdateDate = block.timestamp;
    }

    function getCarcassData(
        uint256 tokenId
    ) external view returns (CarcassInfo memory) {
        return _tokenCarcassData[tokenId];
    }

    function createDemiCarcass(
        uint256 tokenId,
        uint256 demiCarcassAWeight,
        uint256 demiCarcassBWeight,
        uint256 carcassId
    ) external {
        // needs more details
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
