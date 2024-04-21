pragma solidity ^0.8.0;
import "./BaseData.sol";

abstract contract ManufacturedProductData is BaseData {

    struct ManufacturedProductInfo {
        uint256 dateOfManufacturation;
        string productName;
        TimingInfo timingInfo;
        uint256[] meatIds; // Changer meatId en une liste de uint
        uint256 price;
        string description;
        string category;
    }

    mapping(uint256 => ManufacturedProductInfo) private _tokenProductData;

    function createProductData(uint256 tokenId, uint256[] memory meatIds) internal {
        ManufacturedProductInfo storage product = _tokenProductData[tokenId];
        product.meatIds = meatIds;
        product.timingInfo.creationDate = block.timestamp;
        product.category = "ManufacturedProduct";
    }

    function createManufacturedProductAll(
        uint256 tokenId,
        uint256[] memory meatIds,
        string memory productName,
        uint256 price,
        string memory description
    ) internal {
        // Créer une nouvelle instance de produit manufacturé
        ManufacturedProductInfo storage product = _tokenProductData[tokenId];

        // Remplir les détails du produit
        product.meatIds = meatIds;
        product.productName = productName;
        product.price = price;
        product.description = description;
        product.timingInfo.creationDate = block.timestamp;
        product.category = "ManufacturedProduct";
    }

    function setManufacturedProductData(
        uint256 tokenId,
        uint256 dateOfManufacturation,
        string memory productName,
        uint256 price,
        string memory description
    ) internal {
        ManufacturedProductInfo storage product = _tokenProductData[tokenId];
        product.dateOfManufacturation = dateOfManufacturation;
        product.productName = productName;
        product.timingInfo.lastUpdateDate = block.timestamp;
        product.price = price; 
        product.description = description;
    }

    function getManufacturedProductData(
        uint256 tokenId
    ) internal view returns (ManufacturedProductInfo memory) {
        return _tokenProductData[tokenId];
    }
}
