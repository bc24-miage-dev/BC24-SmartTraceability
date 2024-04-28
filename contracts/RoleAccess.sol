pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "./libraries/categoryTypes.sol";
import "./interfaces/IRoleAccess.sol";
import "./libraries/RoleAccessUtils.sol";

contract RoleAccess is Initializable, IRoleAccess, AccessControlUpgradeable {
    //TODO: only contract should be able to set data
    uint256 private _nextTokenId;

    mapping(uint256 => address) private tokenOwners;

    mapping(uint256 => CategoryTypes.Types) private tokenCategoryTypes;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin) public initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    function setOwnerOfToken(uint256 tokenId, address owner) external {
        tokenOwners[tokenId] = owner;
    }

    function getOwnerOfToken(uint256 tokenId) external view returns (address) {
        return tokenOwners[tokenId];
    }

    function getTokensOfOwner(
        address owner
    ) external view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_nextTokenId);
        uint256 counter = 0;
        for (uint256 i = 0; i < _nextTokenId; i++) {
            if (tokenOwners[i] == owner) {
                result[counter] = i;
                counter++;
            }
        }
        // resize the array
        uint256[] memory finalResult = new uint256[](counter);
        for (uint256 i = 0; i < counter; i++) {
            finalResult[i] = result[i];
        }
        return finalResult;
    }

    function setTokenCategoryType(
        uint256 tokenId,
        CategoryTypes.Types categoryType
    ) external {
        tokenCategoryTypes[tokenId] = categoryType;
    }

    function getTokenCategoryType(
        uint256 tokenId
    ) external view returns (CategoryTypes.Types) {
        return tokenCategoryTypes[tokenId];
    }

    function setNextTokenId(uint256 nextTokenId) external {
        _nextTokenId = nextTokenId;
    }

    function getNextTokenId() external view returns (uint256) {
        return _nextTokenId;
    }

    function getTokensOfCategoryType(
        string memory categoryType
    ) external view override returns (uint256[] memory) {
        CategoryTypes.Types dataType = CategoryTypes.stringToDataType(
            categoryType
        );
        uint256[] memory result = new uint256[](_nextTokenId);
        uint256 counter = 0;
        for (uint256 i = 0; i < _nextTokenId; i++) {
            if (tokenCategoryTypes[i] == dataType) {
                result[counter] = i;
                counter++;
            }
        }
        // resize the array
        uint256[] memory finalResult = new uint256[](counter);
        for (uint256 i = 0; i < counter; i++) {
            finalResult[i] = result[i];
        }
        return finalResult;
    }

    function onlyBreederRole(address sender) external view returns (bool) {
        return hasRole(RoleAccessUtils.BREEDER_ROLE, sender);
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
