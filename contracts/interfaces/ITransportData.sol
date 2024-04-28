pragma solidity ^0.8.0;

interface ITransportData {
    struct TimingInfo {
        uint256 creationDate;
        uint256 lastUpdateDate;
    }
    struct TransportInfo {
        uint256 duration;
        uint256 temperature;
        uint256 humidity;
        TimingInfo timingInfo;
        uint256 animalId;
        string category;
        bool isContaminated;
    }

    function createTransportData(address receiver, uint256 animalId) external;

    function setTransportData(
        uint256 tokenId,
        uint256 duration,
        uint256 temperature,
        uint256 humidity,
        bool isContaminated
    ) external;

    function getTransportData(
        uint256 tokenId
    ) external view returns (TransportInfo memory);
}
