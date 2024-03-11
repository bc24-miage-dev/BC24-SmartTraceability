pragma solidity ^0.8.20;

abstract contract SupplyChainData {
    // Struct for Breeder
    struct BreederInfo {
        string placeOfOrigin;
        string gender;
        uint256 weight;
        string healthInformation;
        uint256 creationDate;
        // mapping(uint256 => uint256) foodConsumption; // Map day number to food consumed
    }

    struct RenderingPlantInfo {
        string countryOfSlaughter;
        uint256 slaughterhouseAccreditationNumber;
        uint256 slaughterDate;
    }

    struct MetaData {
        BreederInfo breeder;
        RenderingPlantInfo renderingPlant;
        /*CarrierInfo carrier;
        FactoryInfo factory; */
    }

    mapping(uint256 => MetaData) _tokenMetadata;

    function setBreederInfo(
        uint256 _tokenId,
        string memory _placeOfOrigin,
        string memory _gender,
        uint256 _weight,
        string memory _healthInformation,
        uint256 _creationDate
    ) public {
        _tokenMetadata[_tokenId].breeder = BreederInfo({
            placeOfOrigin: _placeOfOrigin,
            gender: _gender,
            weight: _weight,
            healthInformation: _healthInformation,
            creationDate: _creationDate
        });
    }

    function setRenderingPlantInfo(
        uint256 _tokenId,
        string memory _countryOfSlaughter,
        uint256 _slaughterhouseAccreditationNumber,
        uint256 _slaughterDate
    ) public {
        _tokenMetadata[_tokenId].renderingPlant = RenderingPlantInfo({
            countryOfSlaughter: _countryOfSlaughter,
            slaughterhouseAccreditationNumber: _slaughterhouseAccreditationNumber,
            slaughterDate: _slaughterDate
        });
    }

    function getSupplyChainData(
        uint256 _tokenId
    ) public view returns (MetaData memory) {
        return _tokenMetadata[_tokenId];
    }

    function deleteSupplyChainData(uint256 _tokenId) public {
        delete _tokenMetadata[_tokenId];
    }
}

/* function getPlaceOfOrigin(
        uint256 _tokenId
    ) public view returns (string memory) {
        return _tokenMetadata[_tokenId].breeder.placeOfOrigin;
    }

    function getGender(uint256 _tokenId) public view returns (string memory) {
        return _tokenMetadata[_tokenId].breeder.gender;
    }

    function getWeight(uint256 _tokenId) public view returns (uint256) {
        return _tokenMetadata[_tokenId].breeder.weight;
    }

    function getHealthInformation(
        uint256 _tokenId
    ) public view returns (string memory) {
        return _tokenMetadata[_tokenId].breeder.healthInformation;
    }

    function getCreationDate(uint256 _tokenId) public view returns (uint256) {
        return _tokenMetadata[_tokenId].breeder.creationDate;
    } */

/*  // Struct for Rendering Plant
    struct RenderingPlantInfo {
        string countryOfSlaughter;
        uint256 slaughterhouseAccreditationNumber;
        uint256 slaughterDate;
    }

    // Struct for Carrier (picking up meat carcasses)
    struct CarrierInfo {
        uint256 refrigeratorTemperature;
        uint256 humidity;
    }

    // Struct for Factory
    struct FactoryInfo {
        uint256 factoryCuttingAccreditationNumber;
        uint256 cuttingDate;
        string countryOfCutting;
    }
 */

// Mapping to track rendering plants
/*    mapping(address => RenderingPlantInfo) public renderingPlants;

    // Mapping to track carriers
    mapping(address => CarrierInfo) public carriers;

    // Mapping to track factories
    mapping(address => FactoryInfo) public factories; */

// Struct for Token Metadata
