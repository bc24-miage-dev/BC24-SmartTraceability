pragma solidity ^0.8.0;

interface IManufacturedProductData {

    struct TimingInfo {
        uint256 creationDate;
        uint256 lastUpdateDate;
    }

      struct ManufacturedProductInfo {
        uint256 dateOfManufacturation;
        string productName;
        TimingInfo timingInfo;
        uint256[] meatIds; 
        uint256 price;
        string description;
        string category;
    }

    function createManufacturedProductData(
        uint256[] memory meatIds,
        string memory productName,
        uint256 price,
        string memory description
    ) external;

    function setManufacturedProductData(
        uint256 tokenId,
        uint256 dateOfManufacturation,
        string memory productName,
        uint256 price,
        string memory description
    ) external;

    function getManufacturedProductData(
        uint256 tokenId
    ) external view returns (ManufacturedProductInfo memory);
}