pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/ITransportData.sol";

contract TransportData is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    ITransportData
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

    mapping(uint256 => TransportInfo) private _tokenTransportData;

    function createTransportData(uint256 tokenId) external {
        TransportInfo storage transport = _tokenTransportData[tokenId];
        transport.timingInfo.creationDate = block.timestamp;
        transport.category = "Transport";
    }

    function setTransportData(
        uint256 tokenId,
        uint256 duration,
        uint256 temperature,
        uint256 humidity,
        bool isContaminated
    ) external {
        TransportInfo storage transport = _tokenTransportData[tokenId];
        transport.duration = duration;
        transport.temperature = temperature;
        transport.humidity = humidity;
        transport.isContaminated = isContaminated;
        transport.timingInfo.lastUpdateDate = block.timestamp;
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
