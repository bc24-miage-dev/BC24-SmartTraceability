pragma solidity ^0.8.20;

interface ICarcassData {
    struct TimingInfo {
        uint256 creationDate;
        uint256 lastUpdateDate;
    }

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

    function createCarcassData(uint256 animalId) external;

    function createDemiCarcass(
        uint256 tokenId,
        uint256 demiCarcassAWeight,
        uint256 demiCarcassBWeight,
        uint256 carcassId
    ) external;

    function getCarcassData(
        uint256 tokenId
    ) external view returns (CarcassInfo memory);

    function setCarcassData(
        uint256 tokenId,
        string memory agreementNumber,
        string memory countryOfSlaughter,
        uint256 dateOfSlaughter,
        uint256 carcassWeight,
        bool isContaminated
    ) external;

    function test() external pure returns (string memory);
}
