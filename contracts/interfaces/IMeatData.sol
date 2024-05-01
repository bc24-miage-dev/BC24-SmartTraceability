pragma solidity ^0.8.0;

interface IMeatData {
    struct TimingInfo {
        uint256 creationDate;
        uint256 lastUpdateDate;
    }
    struct MeatInfo {
        string agreementNumber;
        string countryOfCutting;
        uint256 dateOfCutting;
        uint256 carcassId;
        string category;
        string part;
        bool isContaminated;
        uint256 weight;
        TimingInfo timingInfo;
    }

    function createMeatData(
        uint256 carcassId,
        string memory part,
        uint256 weight
    ) external;

    function setMeatData(
        uint256 tokenId,
        string memory agreementNumber,
        string memory countryOfCutting,
        uint256 dateOfCutting,
        string memory part,
        bool isContaminated,
        uint256 weight
    ) external;

    function getMeatData(
        uint256 tokenId
    ) external view returns (MeatInfo memory);

    function checkMeatCategory(
        uint256 tokenId,
        string memory requiredCategory
    ) external view returns (bool);

    function checkMeatWeight(
        uint256 tokenId,
        uint256 requiredWeight
    ) external view returns (bool);

    function checkMeatPart(
        uint256 tokenId,
        string memory requiredPart
    ) external view returns (bool);

    function updateMeatWeight(uint256 tokenId, uint256 newWeight) external;
}
