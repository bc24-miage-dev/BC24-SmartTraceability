pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";

library RoleAccess {
    // general roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // specific roles
    bytes32 public constant BREEDER_ROLE = keccak256("BREEDER_ROLE");
    bytes32 public constant TRANSPORTER_ROLE = keccak256("TRANSPORTER_ROLE");
    bytes32 public constant SLAUGHTER_ROLE = keccak256("SLAUGHTER_ROLE");
    bytes32 public constant MANUFACTURERE_ROLE =
        keccak256("MANUFACTURERE_ROLE");
    bytes32 public constant SELLER_ROLE = keccak256("SELLER_ROLE");

    // other roles
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant TOKEN_OWNER_ROLE = keccak256("OWNER_ROLE");

    function getRoleFromString(
        string memory role
    ) internal pure returns (bytes32) {
        if (
            keccak256(abi.encodePacked(role)) ==
            keccak256(abi.encodePacked("MINTER_ROLE"))
        ) {
            return MINTER_ROLE;
        } else if (
            keccak256(abi.encodePacked(role)) ==
            keccak256(abi.encodePacked("BREEDER_ROLE"))
        ) {
            return BREEDER_ROLE;
        } else if (
            keccak256(abi.encodePacked(role)) ==
            keccak256(abi.encodePacked("TRANSPORTER_ROLE"))
        ) {
            return TRANSPORTER_ROLE;
        } else if (
            keccak256(abi.encodePacked(role)) ==
            keccak256(abi.encodePacked("SLAUGHTER_ROLE"))
        ) {
            return SLAUGHTER_ROLE;
        } else if (
            keccak256(abi.encodePacked(role)) ==
            keccak256(abi.encodePacked("MANUFACTURERE_ROLE"))
        ) {
            return MANUFACTURERE_ROLE;
        } else {
            revert("Invalid role");
        }
    }
}
