import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";
import { SetupService } from "./setupService";

describe("BC24-Breeder", function () {
  let defaultAdmin: any;
  let minter: any;
  let transporter: any;
  let slaughterer: any;
  let breeder: any;
  let contract: any;
  let random: any;

  let setupService: any;

  beforeEach(async function () {
    /* This it the general setup needed for all the contracts*/
    /* If a new contract is put into an interface it needs to be added likewise in the SetupService */
    setupService = new SetupService();
    await setupService.setup();

    defaultAdmin = setupService.defaultAdmin;
    minter = setupService.minter;
    breeder = setupService.breeder;
    transporter = setupService.transporter;
    slaughterer = setupService.slaughterer;
    random = setupService.random;
    contract = setupService.contract;
  });
  it("Test contract", async function () {
    expect(await contract.uri(0)).to.equal("");
  });

  it("should allow the breeder role to create animal", async function () {
    await expect(
      await contract
        .connect(breeder)
        .createAnimal(breeder.address, "Cow", 10, "male")
    )
      .to.emit(contract, "NFTMinted")
      .withArgs(0n, breeder.address, "AnimalNFT created");

    const indexAfterMint = await contract.getTokenIndex();
    expect(indexAfterMint).to.equal(1);
  });

  it("should show all tokens of a breeder", async function () {
    await contract
      .connect(breeder)
      .createAnimal(breeder.address, "Cow", 10, "male");

    await contract
      .connect(breeder)
      .createAnimal(breeder.address, "Cow", 10, "female");

    await contract
      .connect(breeder)
      .createAnimal(breeder.address, "Cow", 20, "male");

    const tokenIds = await contract.connect(breeder).getTokensOfOwner();

    expect(tokenIds.length).to.equal(3);
    expect(tokenIds[0]).to.equal(0);
    expect(tokenIds[1]).to.equal(1);
    expect(tokenIds[2]).to.equal(2);
  });

  it("should throw when others than breeder try to create animal", async function () {
    await expect(
      contract
        .connect(defaultAdmin)
        .createAnimal(defaultAdmin.address, "Cow", 10, "male")
    ).to.be.revertedWith("Caller is not a breeder");
  });

  it("should mint animal and increment _nextTokenId", async function () {
    await expect(
      contract.connect(breeder).createAnimal(breeder.address, "Cow", 10, "male")
    )
      .to.emit(contract, "NFTMinted")
      .withArgs(0n, breeder.address, "AnimalNFT created");

    await expect(
      contract.connect(breeder).createAnimal(breeder.address, "Cow", 10, "male")
    )
      .to.emit(contract, "NFTMinted")
      .withArgs(1n, breeder.address, "AnimalNFT created");

    const indexAfterMint = await contract.getTokenIndex();
    expect(indexAfterMint).to.equal(2);
  });

  it("should create an animal successfully", async () => {
    await contract
      .connect(breeder)
      .createAnimal(breeder.address, "Cow", 10, "male");

    // Create some sample data
    const placeOfOrigin = "Farm XYZ";
    const dateOfBirth = 1622524800; // June 1, 2021
    const gender = "Male";
    const weight = 1000;
    const sicknessList: [] = []; // Empty list
    const vaccinationList: [] = []; // Empty list
    const foodList: [] = []; // Empty lis
    const isContaminated = false;

    await expect(
      await contract
        .connect(breeder)
        .updateAnimal(
          0,
          placeOfOrigin,
          dateOfBirth,
          gender,
          weight,
          sicknessList,
          vaccinationList,
          foodList,
          isContaminated
        )
    )
      .to.emit(contract, "MetaDataChanged")
      .withArgs(0n, breeder.address, "Breeding info changed.");

    const animalData = await contract.connect(breeder).getAnimal(0);
    expect(animalData.placeOfOrigin).to.equal(placeOfOrigin);
    expect(animalData.dateOfBirth).to.equal(dateOfBirth);
    expect(animalData.gender).to.equal(gender);
    expect(animalData.weight).to.equal(weight);
    expect(animalData.sicknessList).to.deep.equal(sicknessList);
    expect(animalData.vaccinationList).to.deep.equal(vaccinationList);
    expect(animalData.foodList).to.deep.equal(foodList);
  });
  it("should not be able to set animalData of another breeder", async () => {
    await contract
      .connect(breeder)
      .createAnimal(breeder.address, "Cow", 10, "male");

    // Create some sample data
    const placeOfOrigin = "Farm XYZ";
    const dateOfBirth = 1622524800; // June 1, 2021
    const gender = "Male";
    const weight = 1000;
    const sicknessList: [] = []; // Empty list
    const vaccinationList: [] = []; // Empty list
    const foodList: [] = []; // Empty lis
    const isContaminated = false;

    await contract
      .connect(defaultAdmin)
      .grantRoleToAddress(random.address, "BREEDER_ROLE");

    await expect(
      contract
        .connect(random)
        .updateAnimal(
          0,
          placeOfOrigin,
          dateOfBirth,
          gender,
          weight,
          sicknessList,
          vaccinationList,
          foodList,
          isContaminated
        )
    ).to.be.revertedWith("Caller does not own this token");
  });

  it("should transfer animal to transporter", async function () {
    await contract
      .connect(breeder)
      .createAnimal(breeder.address, "Cow", 10, "male");

    await expect(contract.connect(transporter).getAnimal(0)).to.be.revertedWith(
      "Caller does not own this token"
    );

    await contract
      .connect(breeder)
      .transferToken(0, transporter.address);

    await expect(contract.connect(breeder).getAnimal(0)).to.be.revertedWith(
      "Caller does not own this token"
    );

    expect(await contract.connect(transporter).ownerOf(0)).to.equal(
      transporter.address
    );
  });
});
