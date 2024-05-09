pragma solidity ^0.8.20;

library CategoryTypes {
    enum Types { Animal, Carcass, Transport, Meat, ManufacturedProduct, Recipe }

    function stringToDataType(string memory dataType) internal pure returns (Types) {
        if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("Animal")))
        ) {
            return Types.Animal;
        } else if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("Carcass")))
        ) {
            return Types.Carcass;
        } else if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("Transport")))
        ) {
            return Types.Transport;
        } else if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("Meat")))
        ) {
            return Types.Meat;
        } else if (
            keccak256(abi.encodePacked((dataType))) ==
            keccak256(abi.encodePacked(("ManufacturedProduct")))
        ) {
            return Types.ManufacturedProduct;
        } else {
            revert("Invalid data type");
        }
    }
}