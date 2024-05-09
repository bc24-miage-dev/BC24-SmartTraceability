pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/ITransportData.sol";
import "./interfaces/IRoleAccess.sol";
import "./interfaces/IOwnerAndCategoryMapper.sol";

import "./libraries/categoryTypes.sol";

contract TransportData is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    ITransportData
{
    IRoleAccess private roleAccessInstance;
    IOwnerAndCategoryMapper private ownerAndCategoryMapperInstance;

    mapping(uint256 => TransportInfo) private _tokenTransportData;

    modifier onlyTransporterRole() {
        require(
            roleAccessInstance.onlyTransporterRole(msg.sender),
            "Caller is not a transporter"
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

    modifier onlyWhenAnimalPresent(uint256 tokenId) {
        TransportInfo storage tokenInfo = _tokenTransportData[tokenId];
        require(
            ownerAndCategoryMapperInstance.getOwnerOfToken(
                tokenInfo.animalId
            ) == msg.sender,
            "Animal is not present or is not owned by the transporter"
        );
        _;
    }

    //emits an event when a new token is created
    event NFTMinted(uint256 tokenId, address owner, string message);

    // emits an event when metadata is changed
    event MetaDataChanged(uint256 tokenId, address owner, string message);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address defaultAdmin,
        address roleAccessContract,
        address ownerAndCategoryMapperAddress
    ) public initializer {
        __ERC1155_init("");
        __AccessControl_init();
        __ERC1155Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);

        roleAccessInstance = IRoleAccess(roleAccessContract);
        ownerAndCategoryMapperInstance = IOwnerAndCategoryMapper(
            ownerAndCategoryMapperAddress
        );
    }

    function createTransportData(
        uint animalId
    ) external onlyTokenOwner(animalId) onlyTransporterRole {
        uint256 tokenId = ownerAndCategoryMapperInstance.getNextTokenId();
        _mint(msg.sender, tokenId, 1, "");
        ownerAndCategoryMapperInstance.setOwnerOfToken(tokenId, msg.sender);
        ownerAndCategoryMapperInstance.setTokenCategoryType(
            tokenId,
            CategoryTypes.Types.Transport
        );
        ownerAndCategoryMapperInstance.setNextTokenId(tokenId + 1);

        TransportInfo storage transport = _tokenTransportData[tokenId];
        transport.timingInfo.creationDate = block.timestamp;
        transport.category = "Transport";
        transport.animalId = animalId;

        emit NFTMinted(tokenId, msg.sender, "TransportNFT created");
    }

    function setTransportData(
        uint256 tokenId,
        uint256 duration,
        uint256 temperature,
        uint256 humidity,
        bool isContaminated
    )
        external
        onlyTokenOwner(tokenId)
        onlyTransporterRole
        onlyWhenAnimalPresent(tokenId)
    {
        TransportInfo storage transport = _tokenTransportData[tokenId];
        transport.duration = duration;
        transport.temperature = temperature;
        transport.humidity = humidity;
        transport.isContaminated = isContaminated;
        transport.timingInfo.lastUpdateDate = block.timestamp;

        emit MetaDataChanged(tokenId, msg.sender, "Transport data updated");
    }

    function getTransportData(
        uint256 tokenId
    ) external view virtual returns (TransportInfo memory) {
        return _tokenTransportData[tokenId];
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
