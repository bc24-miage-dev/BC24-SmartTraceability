pragma solidity ^0.8.0;
import "./BaseData.sol";

contract AnimalData is BaseData {
    struct AnimalInfo {
        string placeOfOrigin;
        uint256 dateOfBirth;
        string gender;
        uint256 weight;
        string[] sicknessList;
        string[] vaccinationList;
        uint256[] foodList;
        // for for dates
        TimingInfo timingInfo;
        //string typeOfAnimal;
        bool isDead;
    }

    mapping(uint256 => AnimalInfo) private _tokenAnimalData;

    function createAnimalData(uint256 tokenId) internal {
        AnimalInfo storage animalInfo = _tokenAnimalData[tokenId];
        animalInfo.timingInfo.creationDate = block.timestamp;
    }

    function setAnimalData(
        uint256 tokenId,
        string memory placeOfOrigin,
        uint256 dateOfBirth,
        string memory gender,
        uint256 weight,
        string[] memory sicknessList,
        string[] memory vaccinationList,
        uint256[] memory foodList
    ) internal {
        AnimalInfo storage animal = _tokenAnimalData[tokenId];
        animal.placeOfOrigin = placeOfOrigin;
        animal.dateOfBirth = dateOfBirth;
        animal.gender = gender;
        animal.weight = weight;
        animal.sicknessList = sicknessList;
        animal.vaccinationList = vaccinationList;
        animal.foodList = foodList;
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
        require(animal.isDead == false, "Animal already has been slaughtered"); 
        animal.isDead = true;
    }
}
