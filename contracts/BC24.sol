// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./AnimalData.sol";
import "./TransportData.sol";

/// @custom:security-contact Hugo.albert.marques@gmail.com
contract BC24 is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    AnimalData,
    TransportData
{
    //general roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // specific roles
    bytes32 public constant BREEDER_ROLE = keccak256("BREEDER_ROLE");
    bytes32 public constant TRANSPORTER_ROLE = keccak256("TRANSPORTER_ROLE");

    // other roles
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant TOKEN_OWNER_ROLE = keccak256("OWNER_ROLE");

    uint256 private _nextTokenId;
    mapping(uint256 => address) private tokenOwners;

    //emits an event when a new token is created
    event AnimalNFTMinted(uint256 indexed _id);

    // emits an event when metadata is changed
    event MetaDataChanged(string _message);

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
        } else {
            revert("Invalid role");
        }
    }

    function createAnimal(
        address account
    ) public onlyBreederRole onlyMinterRole returns (uint256) {
        uint256 tokenId = _nextTokenId;
        AnimalData.createAnimalData(tokenId);
        _mint(account, tokenId, 1, "");
        tokenOwners[tokenId] = msg.sender;
        _nextTokenId++;
        emit AnimalNFTMinted(tokenId);
        return tokenId;
    }

    function updateAnimal(
        uint256 tokenId,
        string memory placeOfOrigin,
        uint256 dateOfBirth,
        string memory gender,
        uint256 weight,
        string[] memory sicknessList,
        string[] memory vaccinationList,
        uint256[] memory foodList
    ) public onlyBreederRole onlyTokenOwner(tokenId) returns (string memory) {
        AnimalData.setAnimalData(
            tokenId,
            placeOfOrigin,
            dateOfBirth,
            gender,
            weight,
            sicknessList,
            vaccinationList,
            foodList
        );

        emit MetaDataChanged("Breeding info added successfully.");

        return "Breeding info added successfully.";
    }

    function getAnimal(
        uint256 tokenId
    ) public view onlyTokenOwner(tokenId) returns (AnimalInfo memory) {
        return AnimalData.getAnimalData(tokenId);
    }

    function giveAnimalToTransporter(
        uint256 tokenId,
        address newOwner
    )
        public
        onlyBreederRole
        onlyTokenOwner(tokenId)
        receiverOnlyRole(TRANSPORTER_ROLE, newOwner)
    {
        safeTransferFrom(msg.sender, newOwner, tokenId, 1, "");
        tokenOwners[tokenId] = newOwner;
        TransportData.createTransportData(tokenId);
    }

    function updateTransport(
        uint256 tokenId,
        uint256 duration,
        uint256 temperature,
        uint256 humidity
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
            humidity
        );
        emit MetaDataChanged("Transport info added successfully.");
        return "Transport info added successfully.";
    }

    function getTransport(
        uint256 tokenId
    ) public view onlyTokenOwner(tokenId) returns (TransportInfo memory) {
        return TransportData.getTransportData(tokenId);
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
}
