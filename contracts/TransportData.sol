pragma solidity ^0.8.0;
import "./BaseData.sol";

contract TransportData is BaseData {
    struct TransportInfo {
        uint256 duration;
        uint256 temperature;
        uint256 humidity;
        TimingInfo timingInfo;
    }

    mapping(uint256 => TransportInfo) private _tokenTransportData;

    function createTransportData(uint256 tokenId) internal {
        TransportInfo storage transport = _tokenTransportData[tokenId];
        transport.timingInfo.creationDate = block.timestamp;
    }

    function setTransportData(
        uint256 tokenId,
        uint256 duration,
        uint256 temperature,
        uint256 humidity
    ) public {
        TransportInfo storage transport = _tokenTransportData[tokenId];
        transport.duration = duration;
        transport.temperature = temperature;
        transport.humidity = humidity;
        transport.timingInfo.creationDate = block.timestamp;
        transport.timingInfo.lastUpdateDate = block.timestamp;
    }

    function getTransportData(
        uint256 tokenId
    ) public view virtual returns (TransportInfo memory) {
        return _tokenTransportData[tokenId];
    }
}
