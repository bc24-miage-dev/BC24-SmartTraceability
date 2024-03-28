pragma solidity ^0.8.0;
import "./BaseData.sol";

abstract contract ManufacturedProductData is BaseData {
    struct ManufacturedProductInfo {
        uint256 dateOfManufacturation;
        string productName;
        TimingInfo timingInfo;
        uint256 meatInfoId;
    }

    mapping(uint256 => ManufacturedProductInfo) private _tokenProductData;

    function createProductData(uint256 tokenId) internal {
        ManufacturedProductInfo storage product = _tokenProductData[tokenId];
        product.timingInfo.creationDate = block.timestamp;
    }

    function setData(
        uint256 tokenId,
        uint256 dateOfManufacturation,
        string memory productName,
        uint256 meatInfoId
    ) public {
        ManufacturedProductInfo storage product = _tokenProductData[tokenId];
        product.dateOfManufacturation = dateOfManufacturation;
        product.productName = productName;
        product.meatInfoId = meatInfoId;
        product.timingInfo.creationDate = block.timestamp;
        product.timingInfo.lastUpdateDate = block.timestamp;
    }

    function getData(
        uint256 tokenId
    ) public view returns (ManufacturedProductInfo memory) {
        return _tokenProductData[tokenId];
    }
}
