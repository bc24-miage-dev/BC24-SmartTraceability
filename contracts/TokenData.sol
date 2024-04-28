pragma solidity ^0.8.20;

import "./libraries/categoryTypes.sol";
import "./interfaces/ITokenData.sol";

contract TokenData is ITokenData {
    uint256 private _nextTokenId;

    mapping(uint256 => address) private tokenOwners;

    mapping(uint256 => CategoryTypes.Types) private tokenCategoryTypes;

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
}
