pragma solidity ^0.8.0;
import "./BaseData.sol";

abstract contract MeatData is BaseData {
    struct MeatInfo {
        string agreementNumber;
        string countryOfCutting;
        uint256 dateOfCutting;
        TimingInfo timingInfo;
        uint256 carcassId; //pas traçeable avec les contrats ? ça fait très bdd sql ça
        string category;
        string part;
        bool isContaminated;
        uint256 weight; // Nouvelle propriété pour stocker le poids du morceau de viande
    }

    mapping(uint256 => MeatInfo) private _tokenMeatData;

    function createMeatData(uint256 tokenId, uint256 carcassId, uint256 weight) internal {
        MeatInfo storage meat = _tokenMeatData[tokenId];
        meat.carcassId = carcassId;
        meat.timingInfo.creationDate = block.timestamp;
        meat.category = "Meat";
        meat.weight = weight; // Assigner le poids du morceau de viande
    }

    function setMeatData(
        uint256 tokenId,
        string memory agreementNumber,
        string memory countryOfCutting,
        uint256 dateOfCutting,
        string memory part,
        bool isContaminated,
        uint256 weight // Ajouter le poids en tant que paramètre
    ) internal {
        MeatInfo storage meat = _tokenMeatData[tokenId];
        meat.agreementNumber = agreementNumber;
        meat.countryOfCutting = countryOfCutting;
        meat.dateOfCutting = dateOfCutting;
        meat.part = part;
        meat.timingInfo.lastUpdateDate = block.timestamp;
        meat.isContaminated = isContaminated;
        meat.weight = weight; // Assigner le poids du morceau de viande
    }

    function getMeatData(uint256 tokenId) public view returns (MeatInfo memory) {
        return _tokenMeatData[tokenId];
    }

    // Fonction pour vérifier si la catégorie de viande correspond à celle requise
    function checkMeatCategory(uint256 tokenId, string memory requiredCategory) public view returns (bool) {
        return keccak256(abi.encodePacked(_tokenMeatData[tokenId].category)) == keccak256(abi.encodePacked(requiredCategory));
    }

    // Fonction pour vérifier si le poids de la viande est suffisant
    function checkMeatWeight(uint256 tokenId, uint256 requiredWeight) public view returns (bool) {
        return _tokenMeatData[tokenId].weight >= requiredWeight;
    }

     // Fonction pour vérifier la partie de la viande
    function checkMeatPart(uint256 tokenId, string memory requiredPart) public view returns (bool) {
        return keccak256(abi.encodePacked(_tokenMeatData[tokenId].part)) == keccak256(abi.encodePacked(requiredPart));
    }

    // Fonction pour mettre à jour le poids de la viande
    function updateMeatWeight(uint256 tokenId, uint256 newWeight) internal {
        _tokenMeatData[tokenId].weight = newWeight;
    }
   
}
