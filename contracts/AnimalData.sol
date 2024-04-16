pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IAnimalData.sol";


contract AnimalData is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    UUPSUpgradeable,
    IAnimalData
{
    // other roles
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

    mapping(uint256 => IAnimalData.AnimalInfo) private _tokenAnimalData;

    function createAnimalData(uint256 tokenId, string memory name) external {
        AnimalInfo storage animalInfo = _tokenAnimalData[tokenId];
        animalInfo.timingInfo.creationDate = block.timestamp;
        animalInfo.category = "Animal";
        animalInfo.isLifeCycleOver = false;
        animalInfo.animalType = name;
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
    ) external {
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
    }

    function getAnimalData(
        uint256 tokenId
    ) external view returns (AnimalInfo memory) {
        return _tokenAnimalData[tokenId];
    }

    function killAnimal(uint256 animalId) external {
        AnimalInfo storage animal = _tokenAnimalData[animalId];
        require(
            animal.isLifeCycleOver == false,
            "Animal already has been slaughtered"
        );
        animal.isLifeCycleOver = true;
    }

    function test() external pure returns (string memory) {
        return "hi there";
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

    function createAnimalData(
        uint256 tokenId,
        string memory animalType,
        uint256 weight,
        string memory gender
    ) external override {}
}