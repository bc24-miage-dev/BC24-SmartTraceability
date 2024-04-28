pragma solidity ^0.8.20;

import "../libraries/categoryTypes.sol";

interface IRoleAccess {
    function setNextTokenId(uint256 count) external;

    function getNextTokenId() external view returns (uint256);

    function setOwnerOfToken(uint256 tokenId, address owner) external;

    function getOwnerOfToken(uint256 tokenId) external view returns (address);

    function getTokensOfOwner(
        address owner
    ) external view returns (uint256[] memory);

    function setTokenCategoryType(
        uint256 tokenId,
        CategoryTypes.Types categoryType
    ) external;

    function getTokenCategoryType(
        uint256 tokenId
    ) external view returns (CategoryTypes.Types);

    function getTokensOfCategoryType(
        string memory categoryType
    ) external view returns (uint256[] memory);

    function onlyBreederRole(address sender) external view returns (bool);

    function grantRoleToAddress(address account, string memory role) external;
}
