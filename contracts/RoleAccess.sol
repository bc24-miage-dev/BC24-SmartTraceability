pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "./libraries/categoryTypes.sol";
import "./interfaces/IRoleAccess.sol";
import "./libraries/RoleAccessUtils.sol";

contract RoleAccess is Initializable, IRoleAccess, AccessControlUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin) public initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    function onlyBreederRole(address sender) external view returns (bool) {
        return hasRole(RoleAccessUtils.BREEDER_ROLE, sender);
    }

    function onlyTransporterRole(address sender) external view returns (bool) {
        return hasRole(RoleAccessUtils.TRANSPORTER_ROLE, sender);
    }

    function onlySlaughterRole(address sender) external view returns (bool) {
        return hasRole(RoleAccessUtils.SLAUGHTER_ROLE, sender);
    }

    function onlyManufacturerRole(address sender) external view returns (bool) {
        return hasRole(RoleAccessUtils.MANUFACTURERE_ROLE, sender);
    }

    function onlySellerRole(address sender) external view returns (bool) {
        return hasRole(RoleAccessUtils.SELLER_ROLE, sender);
    }

    function onlyMinterRole(address sender) external view returns (bool) {
        return hasRole(RoleAccessUtils.MINTER_ROLE, sender);
    }


    function grantRoleToAddress(
        address account,
        string memory role
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 roleHash = RoleAccessUtils.getRoleFromString(role);
        grantRole(roleHash, account);
    }
}
