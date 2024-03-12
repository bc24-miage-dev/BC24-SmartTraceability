import { expect } from "chai";
import { ethers, upgrades } from "hardhat";

describe("BC24", function () {
  let defaultAdmin;
  let minter;
  let upgrader;
  let owner;

  let contract;

  beforeEach(async function () {
    const ContractFactory = await ethers.getContractFactory("BC24");
    defaultAdmin = (await ethers.getSigners())[0];
    minter = (await ethers.getSigners())[1];
    upgrader = (await ethers.getSigners())[2];
    owner = (await ethers.getSigners())[3];

    contract = await upgrades.deployProxy(ContractFactory, [
      defaultAdmin.address,
      minter.address,
      defaultAdmin.address,
      defaultAdmin.address,
    ]);

    await contract.waitForDeployment();
  });

  it("Test contract", async function () {
    expect(await contract.uri(0)).to.equal("");
  });

  it("should allow only the minter role to create tokens", async function () {
    await expect(contract.connect(minter).createToken(minter.address))
      .to.emit(contract, "NFTMinted")
      .withArgs(0);

    const indexAfterMint = await contract.getTokenIndex();
    expect(indexAfterMint).to.equal(1);
  });

  it("should throw when others than minters try to create tokens", async function () {
    await expect(
      contract.connect(defaultAdmin).createToken(defaultAdmin.address)
    ).Throw;
  });

  it("should mint tokens and increment _nextTokenId", async function () {
    await expect(contract.connect(minter).createToken(minter.address))
      .to.emit(contract, "NFTMinted")
      .withArgs(0);

    await expect(contract.connect(minter).createToken(minter.address))
      .to.emit(contract, "NFTMinted")
      .withArgs(1);

    const indexAfterMint = await contract.getTokenIndex();
    expect(indexAfterMint).to.equal(2);
  });

  it("should add breeding info successfully", async () => {
    await contract.connect(minter).createToken(minter.address);

    const tokenId = 0;
    const typeOfAnimal = "Dog";
    const placeOfOrigin = "USA";
    const gender = "Male";
    const weight = 10;
    const healthInformation = "Healthy";

    await expect(contract.addBreedingInfo(
        tokenId,
        typeOfAnimal,
        placeOfOrigin,
        gender,
        weight,
        healthInformation
      )
    )
      .to.emit(contract, "MetaDataChanged")
      .withArgs("Breeding info added successfully.");

    //maybe call getMetaData and check if the data is correct
  });

  it("should add rendering plant info successfully", async () => {
    await contract.connect(minter).createToken(minter.address);

    const tokenId = 0;
    const countryOfSlaughter = "USA";
    const slaughterhouseAccreditationNumber = 123456;
    const slaughterDate = Math.floor(Date.now() / 1000);

    await expect(
      contract.addRenderingPlantInfo(
        tokenId,
        countryOfSlaughter,
        slaughterhouseAccreditationNumber,
        slaughterDate
      )
    )
      .to.emit(contract, "MetaDataChanged")
      .withArgs("Rendering plant info added successfully.");

    // Check that the event was emitted
  });
});
