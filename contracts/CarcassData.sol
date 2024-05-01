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
    IOwnerAndCategoryMapper private ownerAndCategoryMapperInstance;

    mapping(uint256 => ICarcassData.CarcassInfo) private _tokenCarcassData;

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

    /* Access controllers */
    modifier onlyCarcassNFT(uint256 tokenId) {
        require(
            ownerAndCategoryMapperInstance.getTokenCategoryType(tokenId) ==
                CategoryTypes.Types.Carcass,
            "Token is not an carcass NFT"
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

    modifier onlyToTransporterORManufacturerReceiver(address receiver) {
        require(
            roleAccessInstance.onlyTransporterRole(receiver) ||
                roleAccessInstance.onlyManufacturerRole(receiver),
            "Receiver is neither a transporter nor a manufacturer"
        );
        _;
    }

    modifier onlySlaughterRole() {
        require(
            roleAccessInstance.onlySlaughterRole(msg.sender),
            "Caller is not a slaughterer"
        );
        _;
    }

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
    )
        external
        onlySlaughterRole
        onlyCarcassNFT(tokenId)
        onlyTokenOwner(tokenId)
    {
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
    ) external onlyCarcassNFT(tokenId) onlyTokenOwner(tokenId) {
        //
    }

    function transferCarcass(
        uint256 tokenId,
        address receiver
    )
        external
        onlyCarcassNFT(tokenId)
        onlyTokenOwner(tokenId)
        onlyToTransporterORManufacturerReceiver(receiver)
    {
        safeTransferFrom(msg.sender, receiver, tokenId, 1, "");
        ownerAndCategoryMapperInstance.setOwnerOfToken(tokenId, receiver);
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
