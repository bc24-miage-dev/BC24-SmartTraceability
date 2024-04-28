import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";
import { SetupService } from "./setupService";
import { token } from "../typechain-types/@openzeppelin/contracts";

describe("BC24-Breeder", function () {
  let defaultAdmin: any;
  let minter: any;
  let transporter: any;
  let slaughterer: any;
  let breeder: any;
  let random: any;
  let bc24: any;
  let animalContract: any;
  let roleAccessContract: any;
  let ownerAndCategoryMapperContract: any;

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
    bc24 = setupService.bc24;
    animalContract = setupService.animalContract;
    roleAccessContract = setupService.roleAccessContract;
    ownerAndCategoryMapperContract = setupService.ownerAndCategoryMapperContract;
    
  });

  it("Test contract", async function () {
    expect(await bc24.uri(0)).to.equal("");
    expect(await animalContract.uri(0)).to.equal("");
  });

  it("should allow the breeder role to create animal", async function () {
    await expect(
      await animalContract.connect(breeder).createAnimalData("Cow", 10, "male")
    )
      .to.emit(animalContract, "NFTMinted")
      .withArgs(0n, breeder.address, "AnimalNFT created");
  });

  it("should show all tokens of a breeder", async function () {
    await animalContract.connect(breeder).createAnimalData("Cow", 10, "male");

    await animalContract.connect(breeder).createAnimalData("Cow", 10, "male");

    await animalContract.connect(breeder).createAnimalData("Cow", 10, "male");

    const tokenIds = await bc24.connect(breeder).getTokensOfOwner();

    expect(tokenIds.length).to.equal(3);
    expect(tokenIds[0]).to.equal(0);
    expect(tokenIds[1]).to.equal(1);
    expect(tokenIds[2]).to.equal(2);
  });

  it("should throw when others than breeder try to create animal", async function () {
    await expect(
      animalContract.connect(defaultAdmin).createAnimalData("Cow", 10, "male")
    ).to.be.revertedWith("Caller is not a breeder");
  });

  it("should create an animal successfully", async () => {
    await animalContract.connect(breeder).createAnimalData("Cow", 10, "male");

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
      await animalContract
        .connect(breeder)
        .setAnimalData(
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
      .to.emit(animalContract, "MetaDataChanged")
      .withArgs(0n, breeder.address, "Animal info changed.");

    const animalData = await animalContract.connect(breeder).getAnimalData(0);
    expect(animalData.placeOfOrigin).to.equal(placeOfOrigin);
    expect(animalData.dateOfBirth).to.equal(dateOfBirth);
    expect(animalData.gender).to.equal(gender);
    expect(animalData.weight).to.equal(weight);
    expect(animalData.sicknessList).to.deep.equal(sicknessList);
    expect(animalData.vaccinationList).to.deep.equal(vaccinationList);
    expect(animalData.foodList).to.deep.equal(foodList);
  });
  it("should not be able to set animalData of another breeder", async () => {
    await animalContract.connect(breeder).createAnimalData("Cow", 10, "male");

    // Create some sample data
    const placeOfOrigin = "Farm XYZ";
    const dateOfBirth = 1622524800; // June 1, 2021
    const gender = "Male";
    const weight = 1000;
    const sicknessList: [] = []; // Empty list
    const vaccinationList: [] = []; // Empty list
    const foodList: [] = []; // Empty lis
    const isContaminated = false;

    await roleAccessContract
      .connect(defaultAdmin)
      .grantRoleToAddress(random.address, "BREEDER_ROLE");

    await expect(
      animalContract
        .connect(random)
        .setAnimalData(
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
    ).to.be.revertedWith("Caller is not the owner of the token");
  });

  it("should transfer animal to transporter", async function () {
    await animalContract.connect(breeder).createAnimalData("Cow", 10, "male");

    await animalContract
      .connect(breeder)
      .transferAnimalToTransporter(0, transporter.address);

    await expect(
      ownerAndCategoryMapperContract.connect(breeder).getTokensOfOwner(breeder.address)
    ).to.eventually.have.lengthOf(0);

    await expect(
      ownerAndCategoryMapperContract.connect(transporter).getTokensOfOwner(transporter.address)
    ).to.eventually.have.lengthOf(2);
  });
});
