pragma solidity ^0.8.0;
import "./BaseData.sol";

abstract contract ManufacturedProductData is BaseData {
    struct ManufacturedProductInfo {
        uint256 dateOfManufacturation;
        string productName;
        TimingInfo timingInfo;
        uint256 meatId;
    }

    mapping(uint256 => ManufacturedProductInfo) private _tokenProductData;

    function createProductData(uint256 tokenId, uint256 meatId) internal {
        ManufacturedProductInfo storage product = _tokenProductData[tokenId];
        product.meatId = meatId;
        product.timingInfo.creationDate = block.timestamp;
    }

    function setManufacturedProductData(
        uint256 tokenId,
        uint256 dateOfManufacturation,
        string memory productName
    ) internal {
        ManufacturedProductInfo storage product = _tokenProductData[tokenId];
        product.dateOfManufacturation = dateOfManufacturation;
        product.productName = productName;
        product.timingInfo.lastUpdateDate = block.timestamp;
    }

    function getManufacturedProductData(
        uint256 tokenId
    ) internal view returns (ManufacturedProductInfo memory) {
        return _tokenProductData[tokenId];
    }
}
