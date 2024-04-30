import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";
import { SetupService } from "./setupService";

describe("BC24-Transporter", function () {
  let defaultAdmin: { address: unknown };
  let minter: { address: unknown };
  let random: any;
  let breeder: any;
  let transporter: any;
  let slaughterer: any;

  let animalId: any;
  let transportId: any;

  let bc24: any;
  let animalContract: any;
  let roleAccessContract: any;
  let ownerAndCategoryMapperContract: any;
  let transportContract: any;

  let setupService: any;

  beforeEach(async function () {
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
    transportContract = setupService.transportContract;
    ownerAndCategoryMapperContract =
      setupService.ownerAndCategoryMapperContract;

    const animalCreation = await animalContract
      .connect(breeder)
      .createAnimalData("Cow", 10, "male");

    const animalCreationReceipt = await animalCreation.wait();
    animalId = animalCreationReceipt.logs[1].args[0];

    await animalContract
      .connect(breeder)
      .transferAnimal(animalId, transporter.address);
  });

  it("Test contract", async function () {
    expect(await bc24.uri(0)).to.equal("");
    expect(
      await ownerAndCategoryMapperContract
        .connect(transporter)
        .getOwnerOfToken(animalId)
    ).to.equal(transporter.address);
  });

  it("should allow the transporter to create transporter data after he received an animal", async function () {
    const duration = 1000;
    const temperature = 25;
    const humidity = 50;
    const isContaminated = false;

    const transportCreation = await transportContract
      .connect(transporter)
      .createTransportData(animalId);

    const transportCreationReceipt = await transportCreation.wait();
    transportId = transportCreationReceipt.logs[1].args[0];

    await expect(
      await transportContract
        .connect(transporter)
        .setTransportData(
          transportId,
          duration,
          temperature,
          humidity,
          isContaminated
        )
    )
      .to.emit(transportContract, "MetaDataChanged")
      .withArgs(transportId, transporter.address, "Transport data updated");

    const transportData = await transportContract
      .connect(transporter)
      .getTransportData(transportId);

    expect(transportData.duration).to.equal(duration);
    expect(transportData.temperature).to.equal(temperature);
    expect(transportData.humidity).to.equal(humidity);
  });

  it("should not allow transporter to change animal", async function () {
    // Create some sample data
    const placeOfOrigin = "Farm XYZ";
    const dateOfBirth = 1622524800; // June 1, 2021
    const gender = "Male";
    const weight = 1000;
    const sicknessList: [] = []; // Empty list
    const vaccinationList: [] = []; // Empty list
    const foodList: [] = []; // Empty list
    const isContaminated = false;

    await expect(
      animalContract
        .connect(transporter)
        .setAnimalData(
          animalId,
          placeOfOrigin,
          dateOfBirth,
          gender,
          weight,
          sicknessList,
          vaccinationList,
          foodList,
          isContaminated
        )
    ).to.be.revertedWith("Caller is not a breeder");
  });

  it("should transfer animal to slaughterer", async function () {
    const balance = await animalContract.balanceOf(
      transporter.address,
      animalId
    );

    //console.log(`Balance of token ${animalId} for wallet ${transporter.address}: ${balance}`);

    await animalContract
      .connect(transporter)
      .transferAnimal(animalId, slaughterer.address);
    expect(
      await ownerAndCategoryMapperContract
        .connect(slaughterer)
        .getOwnerOfToken(animalId)
    ).to.equal(slaughterer.address);
  });

  it("should not allow to transfer Transport NFTs", async function () {
    const transportCreation = await transportContract
      .connect(transporter)
      .createTransportData(animalId);

    const transportCreationReceipt = await transportCreation.wait();
    transportId = transportCreationReceipt.logs[1].args[0];

    await expect(
      animalContract
        .connect(transporter)
        .transferAnimal(transportId, slaughterer.address)
    ).to.be.revertedWith("Token is not an animal NFT");
  });

  it("should not allow transporter to change transport when it has been given away", async function () {
    const transportCreation = await transportContract
      .connect(transporter)
      .createTransportData(animalId);

    const transportCreationReceipt = await transportCreation.wait();
    transportId = transportCreationReceipt.logs[1].args[0];

    await animalContract
      .connect(transporter)
      .transferAnimal(animalId, slaughterer.address);

    const duration = 1000;
    const temperature = 25;
    const humidity = 50;
    const isContaminated = false;

    await expect(
      transportContract
        .connect(transporter)
        .setTransportData(
          transportId,
          duration,
          temperature,
          humidity,
          isContaminated
        )
    ).to.be.revertedWith(
      "Animal is not present or is not owned by the transporter"
    );
  });
});
