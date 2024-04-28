pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./libraries/categoryTypes.sol";

import "./interfaces/IAnimalData.sol";
import "./interfaces/IRoleAccess.sol";
import "./interfaces/IOwnerAndCategoryMapper.sol";

contract AnimalData is
    Initializable,
    ERC1155Upgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    IAnimalData
{
    IRoleAccess private roleAccessInstance;
    IOwnerAndCategoryMapper private ownerAndCategoryMapperInstance;

    modifier onlyBreederRole() {
        require(
            roleAccessInstance.onlyBreederRole(msg.sender),
            "Caller is not a breeder"
        );
        _;
    }
    /*
    modifier onlySlaughterRole() {
        require(
            hasRole(RoleAccess.SLAUGHTER_ROLE, msg.sender),
            "Caller is not a slaughterer"
        );
        _;
    } */

    modifier onlyTokenOwner(uint256 tokenId) {
        require(
            ownerAndCategoryMapperInstance.getOwnerOfToken(tokenId) ==
                msg.sender,
            "Caller is not the owner of the token"
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

    mapping(uint256 => IAnimalData.AnimalInfo) private _tokenAnimalData;

    function createAnimalData(
        string memory animalType,
        uint256 weight,
        string memory gender
    ) external override onlyBreederRole {
        uint256 tokenId = ownerAndCategoryMapperInstance.getNextTokenId();
        _mint(msg.sender, tokenId, 1, "");
        ownerAndCategoryMapperInstance.setOwnerOfToken(tokenId, msg.sender);
        ownerAndCategoryMapperInstance.setTokenCategoryType(
            tokenId,
            CategoryTypes.Types.Animal
        );
        ownerAndCategoryMapperInstance.setNextTokenId(tokenId + 1);

        AnimalInfo storage animalInfo = _tokenAnimalData[tokenId];
        animalInfo.timingInfo.creationDate = block.timestamp;
        animalInfo.category = "Animal";
        animalInfo.isLifeCycleOver = false;
        animalInfo.weight = weight;
        animalInfo.gender = gender;
        animalInfo.animalType = animalType;

        emit NFTMinted(tokenId, msg.sender, "AnimalNFT created");
    }

    function setAnimalData(
        uint256 tokenId,
        string memory placeOfOrigin,
        uint256 dateOfBirth,
        string memory gender,
        uint256 weight,
        string[] memory sicknessList,
        string[] memory vaccinationList,
        string[] memory foodList,
        bool isContaminated
    ) external override onlyTokenOwner(tokenId) {
        AnimalInfo storage animal = _tokenAnimalData[tokenId];
        animal.placeOfOrigin = placeOfOrigin;
        animal.dateOfBirth = dateOfBirth;
        animal.gender = gender;
        animal.weight = weight;
        for (uint256 i = 0; i < sicknessList.length; i++) {
            animal.sicknessList.push(
                Sickness({
                    sickness: sicknessList[i],
                    date: TimingInfo({
                        creationDate: block.timestamp,
                        lastUpdateDate: block.timestamp
                    })
                })
            );
        }

        for (uint256 i = 0; i < vaccinationList.length; i++) {
            animal.vaccinationList.push(
                Vaccine({
                    vaccine: vaccinationList[i],
                    date: TimingInfo({
                        creationDate: block.timestamp,
                        lastUpdateDate: block.timestamp
                    })
                })
            );
        }

        for (uint256 i = 0; i < foodList.length; i++) {
            animal.foodList.push(
                Food({
                    foodname: foodList[i],
                    quantity: 0,
                    date: TimingInfo({
                        creationDate: block.timestamp,
                        lastUpdateDate: block.timestamp
                    })
                })
            );
        }
        animal.isContaminated = isContaminated;

        animal.timingInfo.lastUpdateDate = block.timestamp;

        _tokenAnimalData[tokenId] = animal;

        emit MetaDataChanged(tokenId, msg.sender, "Animal info changed.");
    }

    function getAnimalData(
        uint256 tokenId
    ) external view returns (AnimalInfo memory) {
        return _tokenAnimalData[tokenId];
    }

    function killAnimal(
        uint256 animalId
    ) external override /* onlySlaughterRole */ {
        AnimalInfo storage animal = _tokenAnimalData[animalId];
        require(
            animal.isLifeCycleOver == false,
            "Animal already has been slaughtered"
        );
        animal.isLifeCycleOver = true;
    }

    function transferAnimal(
        uint256 tokenId,
        address receiver
    ) external onlyTokenOwner(tokenId) {
        safeTransferFrom(msg.sender, receiver, tokenId, 1, "");
        ownerAndCategoryMapperInstance.setOwnerOfToken(tokenId, receiver);
        // TODO: Handle transporter get token vs give token
        // transportDataInstance.createTransportData(tokenId);
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
