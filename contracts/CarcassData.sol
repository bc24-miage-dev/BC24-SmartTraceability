pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/ICarcassData.sol";


contract CarcassData is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    ICarcassData
{
    ///role
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

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

    mapping(uint256 => ICarcassData.CarcassInfo) private _tokenCarcassData;

    function createCarcassData(uint256 tokenId, uint256 animalId) external {
        CarcassInfo storage carcass = _tokenCarcassData[tokenId];
        carcass.timingInfo.creationDate = block.timestamp;
        carcass.animalId = animalId;
        carcass.category = "Carcass";
    }

    function setCarcassData(
        uint256 tokenId,
        string memory agreementNumber,
        string memory countryOfSlaughter,
        uint256 dateOfSlaughter,
        uint256 carcassWeight,
        bool isContaminated
    ) external {
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
