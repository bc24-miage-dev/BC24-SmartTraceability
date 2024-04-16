pragma solidity ^0.8.0;
import "./BaseData.sol";

abstract contract CarcassData is BaseData {
    struct CarcassInfo {
        string agreementNumber;
        string countryOfSlaughter;
        uint256 dateOfSlaughter;
        uint256 carcassWeight;
        TimingInfo timingInfo;
        uint256 animalId;
        string category;
        bool isContaminated;
    }

    mapping(uint256 => CarcassInfo) private _tokenCarcassData;      

    function createCarcassData(uint256 tokenId, uint256 animalId) internal {
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
    ) internal {
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
    ) internal view returns (CarcassInfo memory) {
        return _tokenCarcassData[tokenId];
    }

    function createDemiCarcass(
        uint256 tokenId,
        uint256 demiCarcassAWeight,
        uint256 demiCarcassBWeight,
        uint256 carcassId
    ) internal {
        // needs more details
    }
}
