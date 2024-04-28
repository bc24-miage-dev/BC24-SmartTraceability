pragma solidity ^0.8.20;

interface IAnimalData {
    struct TimingInfo {
        uint256 creationDate;
        uint256 lastUpdateDate;
    }
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

    function createAnimalData(
        string memory animalType,
        uint256 weight,
        string memory gender
    ) external;

    function getAnimalData(
        uint256 tokenId
    ) external view returns (AnimalInfo memory);

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
    ) external;

    function killAnimal(uint256 animalId) external;

    function transferAnimalToTransporter(
        uint256 tokenId,
        address receiver
    ) external;

    function transferAnimalToSlaugtherer(
        uint256 tokenId,
        address receiver
    ) external;
}
