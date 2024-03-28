pragma solidity ^0.8.0;
import "./BaseData.sol";

abstract contract CarcassData is BaseData {
    struct CarcassInfo {
        string agreementNumber;
        string countryOfSlaughter;
        uint256 dateOfSlaughter;
        uint256 carcassWeight;
        TimingInfo timingInfo;
        uint256 animalInfoId;
    }

    mapping(uint256 => CarcassInfo) private _tokenCarcassData;

    function createCarcassData(uint256 tokenId) internal {
        CarcassInfo storage carcass = _tokenCarcassData[tokenId];
        carcass.timingInfo.creationDate = block.timestamp;
    }

    function setData(
        uint256 tokenId,
        string memory agreementNumber,
        string memory countryOfSlaughter,
        uint256 dateOfSlaughter,
        uint256 carcassWeight,
        uint256 animalInfoId
    ) public {
        CarcassInfo storage carcass = _tokenCarcassData[tokenId];
        carcass.agreementNumber = agreementNumber;
        carcass.countryOfSlaughter = countryOfSlaughter;
        carcass.dateOfSlaughter = dateOfSlaughter;
        carcass.carcassWeight = carcassWeight;
        carcass.animalInfoId = animalInfoId;
        carcass.timingInfo.creationDate = block.timestamp;
        carcass.timingInfo.lastUpdateDate = block.timestamp;
    }

    function getData(uint256 tokenId) public view returns (CarcassInfo memory) {
        return _tokenCarcassData[tokenId];
    }
}
