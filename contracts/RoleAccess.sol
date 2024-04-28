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

    /*   modifier onlyTransporterRole() {
        require(
            hasRole(RoleAccessUtils.TRANSPORTER_ROLE, msg.sender),
            "Caller is not a transporter"
        );
        _;
    }

    modifier onlySlaughterRole() {
        require(
            hasRole(RoleAccessUtils.SLAUGHTER_ROLE, msg.sender),
            "Caller is not a slaughterer"
        );
        _;
    }

    modifier onlyManufacturerRole() {
        require(
            hasRole(RoleAccessUtils.MANUFACTURERE_ROLE, msg.sender),
            "Caller is not a slaughterer"
        );
        _;
    }

    modifier onlyMinterRole() {
        require(
            hasRole(RoleAccessUtils.MINTER_ROLE, msg.sender),
            "Caller is not a minter"
        );
        _;
    } 
    
          modifier onlyTokenOwner(uint256 tokenId) {
        require(
            msg.sender == tokenDataInstance.getOwnerOfToken(tokenId),
            "Caller does not own this token"
        );
        _;
    }
    modifier onlyTokenOwnerList(uint256[] memory tokenIds) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                msg.sender == tokenDataInstance.getOwnerOfToken(tokenIds[i]),
                "Caller does not own one of the tokens"
            );
        }
        _;
    }
*/

    function grantRoleToAddress(
        address account,
        string memory role
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 roleHash = RoleAccessUtils.getRoleFromString(role);
        grantRole(roleHash, account);
    }
}
