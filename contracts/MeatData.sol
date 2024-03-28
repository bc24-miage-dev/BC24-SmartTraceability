pragma solidity ^0.8.0;
import "./BaseData.sol";

abstract contract MeatData is BaseData {
    struct MeatInfo {
        string agreementNumber;
        string countryOfCutting;
        uint256 dateOfCutting;
        TimingInfo timingInfo;
        uint256 carcassInfoId;
    }

    mapping(uint256 => MeatInfo) private _tokenMeatData;

    function createMeatData(uint256 tokenId) internal {
        MeatInfo storage meat = _tokenMeatData[tokenId];
        meat.timingInfo.creationDate = block.timestamp;
    }

    function setData(
        uint256 tokenId,
        string memory agreementNumber,
        string memory countryOfCutting,
        uint256 dateOfCutting,
        uint256 carcassInfoId
    ) public {
        MeatInfo storage meat = _tokenMeatData[tokenId];
        meat.agreementNumber = agreementNumber;
        meat.countryOfCutting = countryOfCutting;
        meat.dateOfCutting = dateOfCutting;
        meat.carcassInfoId = carcassInfoId;
        meat.timingInfo.creationDate = block.timestamp;
        meat.timingInfo.lastUpdateDate = block.timestamp;
    }

    function getData(uint256 tokenId) public view returns (MeatInfo memory) {
        return _tokenMeatData[tokenId];
    }
}