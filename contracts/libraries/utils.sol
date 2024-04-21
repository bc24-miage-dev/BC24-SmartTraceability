pragma solidity ^0.8.0;

library Utils {
    enum CategoryType { Animal, Carcass, Transport, Meat, ManufacturedProduct, Recipe }

    function stringToDataType(string memory dataType) internal pure returns (CategoryType) {
        if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("Animal")))
        ) {
            return CategoryType.Animal;
        } else if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("Carcass")))
        ) {
            return CategoryType.Carcass;
        } else if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("Transport")))
        ) {
            return CategoryType.Transport;
        } else if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("Meat")))
        ) {
            return CategoryType.Meat;
        } else if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("ManufacturedProduct")))
        ) {
            return CategoryType.ManufacturedProduct;
        } else {
            revert("Invalid data type");
        }
    }
}