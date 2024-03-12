pragma solidity ^0.8.20;

abstract contract SupplyChainData {
    // Struct for Breeder
    struct BreederInfo {
        string typeOfAnimal;
        string placeOfOrigin;
        string gender;
        uint256 weight;
        string healthInformation;
        uint256 creationDate;
        uint256 lastUpdateDate;
    }

    struct RenderingPlantInfo {
        string countryOfSlaughter;
        uint256 slaughterhouseAccreditationNumber;
        uint256 slaughterDate;
        uint256 creationDate;
        uint256 lastUpdateDate;
    }

    struct MetaData {
        BreederInfo breeder;
        RenderingPlantInfo renderingPlant;  
        uint256 creationDate;
        uint256 lastUpdateDate;
    }

    mapping(uint256 => MetaData) _tokenMetadata;
    
    function createMetaData(uint256 tokenId) internal {
        MetaData storage metaData = _tokenMetadata[tokenId];
        metaData.creationDate = block.timestamp;
    }
    
    function setBreederInfo(
        uint256 tokenId,
        string memory typeOfAnimal,
        string memory placeOfOrigin,
        string memory gender,
        uint256 weight,
        string memory healthInformation
    ) internal {
        
        BreederInfo storage breederInfo = _tokenMetadata[tokenId].breeder;

        // If this is the first invocation, set creation date
        if (breederInfo.creationDate == 0) {
            breederInfo.creationDate = block.timestamp;
        }

        uint256 lastUpdateDate = block.timestamp;
       
        _tokenMetadata[tokenId].breeder = BreederInfo({
            typeOfAnimal: typeOfAnimal,
            placeOfOrigin: placeOfOrigin,
            gender: gender,
            weight: weight,
            healthInformation: healthInformation,
            creationDate: breederInfo.creationDate,
            lastUpdateDate: lastUpdateDate
        });

        _tokenMetadata[tokenId].lastUpdateDate = lastUpdateDate;

    }

    function setRenderingPlantInfo(
        uint256 tokenId,
        string memory countryOfSlaughter,
        uint256 slaughterhouseAccreditationNumber,
        uint256 slaughterDate
    ) internal {
         RenderingPlantInfo storage renderingPlant = _tokenMetadata[tokenId].renderingPlant;

        // If this is the first invocation, set creation date
        if (renderingPlant.creationDate == 0) {
            renderingPlant.creationDate = block.timestamp;
        }

        uint256 lastUpdateDate = block.timestamp;

        _tokenMetadata[tokenId].renderingPlant = RenderingPlantInfo({
            countryOfSlaughter: countryOfSlaughter,
            slaughterhouseAccreditationNumber: slaughterhouseAccreditationNumber,
            slaughterDate: slaughterDate,
            creationDate: renderingPlant.creationDate,
            lastUpdateDate: lastUpdateDate
        });
       
        _tokenMetadata[tokenId].lastUpdateDate = lastUpdateDate;
    }

    function getSupplyChainData(
        uint256 _tokenId
    ) internal view returns (MetaData memory) {
        return _tokenMetadata[_tokenId];
    }

    function deleteSupplyChainData(uint256 _tokenId) internal {
        delete _tokenMetadata[_tokenId];
    }
}

