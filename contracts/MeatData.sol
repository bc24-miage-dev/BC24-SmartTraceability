pragma solidity ^0.8.0;
import "./BaseData.sol";

abstract contract MeatData is BaseData {
    struct MeatInfo {
        string agreementNumber;
        string countryOfCutting;
        uint256 dateOfCutting;
        TimingInfo timingInfo;
        uint256 carcassId;
    }

    mapping(uint256 => MeatInfo) private _tokenMeatData;

    function createMeatData(uint256 tokenId, uint256 carcassId) internal {
        MeatInfo storage meat = _tokenMeatData[tokenId];
        meat.carcassId = carcassId;
        meat.timingInfo.creationDate = block.timestamp;
    }

    function setMeatData(
        uint256 tokenId,
        string memory agreementNumber,
        string memory countryOfCutting,
        uint256 dateOfCutting
    ) internal {
        MeatInfo storage meat = _tokenMeatData[tokenId];
        meat.agreementNumber = agreementNumber;
        meat.countryOfCutting = countryOfCutting;
        meat.dateOfCutting = dateOfCutting;
        meat.timingInfo.lastUpdateDate = block.timestamp;
    }

    function getMeatData(uint256 tokenId) internal view returns (MeatInfo memory) {
        return _tokenMeatData[tokenId];
    }
}