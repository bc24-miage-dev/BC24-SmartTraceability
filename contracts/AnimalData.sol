pragma solidity ^0.8.0;
import "./BaseData.sol";

contract AnimalData is BaseData {
    struct AnimalInfo {
        string placeOfOrigin;
        uint256 dateOfBirth;
        string gender;
        uint256 weight;
        TimingInfo timingInfo;
        bool isLifeCycleOver;
        string category;
        string animalType;
        bool isContaminated;
        Sickness[] sicknessList;
        Vaccine[] vaccinationList;
        Food[] foodList;
    }

    struct Sickness {
        string sickness;
        TimingInfo date;
    }
    
    struct Vaccine {
        string vaccine;
        TimingInfo date;
    }
    
    struct Food {
        string foodname;
        uint256 quantity;
        TimingInfo date;
    }
    
    mapping(uint256 => AnimalInfo) private _tokenAnimalData;

    function createAnimalData(uint256 tokenId, string memory name) internal {
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
        Sickness[] memory sicknessList,
        Vaccine[] memory vaccinationList,
        Food[] memory foodList,
        bool isContaminated
    ) internal {
        AnimalInfo storage animal = _tokenAnimalData[tokenId];
        animal.placeOfOrigin = placeOfOrigin;
        animal.dateOfBirth = dateOfBirth;
        animal.gender = gender;
        animal.weight = weight;
        animal.sicknessList = sicknessList;
        animal.vaccinationList = vaccinationList;
        animal.foodList = foodList;
        animal.isContaminated = isContaminated;

        animal.timingInfo.lastUpdateDate = block.timestamp;

        _tokenAnimalData[tokenId] = animal;
    }

    function getAnimalData(
        uint256 tokenId
    ) public view virtual returns (AnimalInfo memory) {
        return _tokenAnimalData[tokenId];
    }

    function killAnimal(uint256 animalId) internal {
        AnimalInfo storage animal = _tokenAnimalData[animalId];
        require(
            animal.isLifeCycleOver == false,
            "Animal already has been slaughtered"
        );
        animal.isLifeCycleOver = true;
    }
}