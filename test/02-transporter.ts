import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";

describe("BC24-Transporter", function () {
  let defaultAdmin: { address: unknown };
  let minter: { address: unknown };
  let random: any;
  let breeder: any;
  let transporter: any;
  let slaughterer: any;
  let contract: any;
  let animalId: any;

  beforeEach(async function () {
    const ContractFactory = await ethers.getContractFactory("BC24");
    defaultAdmin = (await ethers.getSigners())[0];
    minter = (await ethers.getSigners())[1];
    random = (await ethers.getSigners())[2];
    breeder = (await ethers.getSigners())[3];
    transporter = (await ethers.getSigners())[4];
    slaughterer = (await ethers.getSigners())[5];

    contract = await upgrades.deployProxy(ContractFactory, [
      defaultAdmin.address,
      /*       minter.address,
                  defaultAdmin.address,
                  defaultAdmin.address, */
    ]);

    await contract.waitForDeployment();

    // grant the roles
    await contract
      .connect(defaultAdmin)
      .grantRoleToAddress(minter.address, "MINTER_ROLE");

    await contract
      .connect(defaultAdmin)
      .grantRoleToAddress(breeder.address, "BREEDER_ROLE");
    await contract
      .connect(defaultAdmin)
      .grantRoleToAddress(breeder.address, "MINTER_ROLE");

    await contract
      .connect(defaultAdmin)
      .grantRoleToAddress(transporter.address, "TRANSPORTER_ROLE");
    await contract
      .connect(defaultAdmin)
      .grantRoleToAddress(slaughterer.address, "SLAUGHTER_ROLE");

    const transaction = await contract
      .connect(breeder)
      .createAnimal(breeder.address, "Cow", 10 , "male");
    animalId = transaction.value;
    await contract
      .connect(breeder)
      .transferAnimalToTransporter(animalId, transporter.address);
  });

  it("Test contract", async function () {
    expect(await contract.uri(0)).to.equal("");
    expect(await contract.connect(transporter).ownerOf(animalId)).to.equal(
      transporter.address
    );
  });

  it("should allow the transporter to create transporter data after he received an animal", async function () {
    const duration = 1000;
    const temperature = 25;
    const humidity = 50;
    const isContaminated = false;

    await expect(
      await contract
        .connect(transporter)
        .updateTransport(
          animalId,
          duration,
          temperature,
          humidity,
          isContaminated
        )
    )
      .to.emit(contract, "MetaDataChanged")
      .withArgs("Transport info added successfully.");

    const transportData = await contract
      .connect(transporter)
      .getTransport(animalId);
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
      contract
        .connect(transporter)
        .updateAnimal(
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
    await contract
      .connect(transporter)
      .transferAnimalToSlaugtherer(animalId, slaughterer.address);
    expect(await contract.connect(slaughterer).ownerOf(animalId)).to.equal(
      slaughterer.address
    );
  });

  it("should not allow transporter to change carcass", async function () {
    await contract
      .connect(transporter)
      .transferAnimalToSlaugtherer(animalId, slaughterer.address);
    const transaction = await contract
      .connect(slaughterer)
      .slaughterAnimal(animalId);
    const carcassId = transaction.value;

    await contract
      .connect(slaughterer)
      .transferCarcassToTransporter(carcassId, transporter.address);
    expect(await contract.connect(transporter).ownerOf(carcassId)).to.equal(
      transporter.address
    );

    const agreementNumber = "AG123";
    const countryOfSlaughter = "Country";
    const dateOfSlaughter = Math.floor(Date.now() / 1000);
    const carcassWeight = 100;
    const isContaminated = false;

    await expect(
      contract
        .connect(transporter)
        .updateCarcass(
          carcassId,
          agreementNumber,
          countryOfSlaughter,
          dateOfSlaughter,
          carcassWeight,
          isContaminated
        )
    ).to.revertedWith("Caller is not a slaughterer");
  });
});
