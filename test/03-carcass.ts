import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";

describe("BC24-Carcass", function () {
  let defaultAdmin: { address: unknown };
  let minter: { address: unknown };
  let random: any;
  let transporter: any;
  let slaughterer: any;
  let breeder: any;
  let contract: any;
  let animalId: any;

  beforeEach(async function () {
    const BC24Contract = await ethers.getContractFactory("BC24");
    const CarcassContract = await ethers.getContractFactory("CarcassData");
    defaultAdmin = (await ethers.getSigners())[0];
    minter = (await ethers.getSigners())[1];
    random = (await ethers.getSigners())[2];
    breeder = (await ethers.getSigners())[3];
    transporter = (await ethers.getSigners())[4];
    slaughterer = (await ethers.getSigners())[5];

    const carcassContract = await upgrades.deployProxy(CarcassContract, [
      defaultAdmin.address,
    ]);

    await carcassContract.waitForDeployment();
  
    const carcassDataAddress = await carcassContract.getAddress();

    contract = await upgrades.deployProxy(BC24Contract, [
      defaultAdmin.address, 
      carcassDataAddress
    ]);

    await contract.waitForDeployment();

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
      .createAnimal(breeder.address, "Cow", 10, "male");
    animalId = transaction.value;
    await contract
      .connect(breeder)
      .transferAnimalToTransporter(animalId, transporter.address);
    await contract
      .connect(transporter)
      .transferAnimalToSlaugtherer(animalId, slaughterer.address);
  });

  it("Test contract", async function () {
    expect(await contract.uri(0)).to.equal("");
    expect(await contract.connect(slaughterer).ownerOf(animalId)).to.equal(
      slaughterer.address
    );
  });

  it("should make sure the animal is still alive", async function () {
    const animal = await contract.connect(slaughterer).getAnimal(animalId);
    expect(await animal.isLifeCycleOver).to.equal(false);
  });

  it("should create a new carcassNFT which is connected to the now dead animal", async function () {
    const transaction = await contract
      .connect(slaughterer)
      .slaughterAnimal(animalId);

    const animal = await contract.connect(slaughterer).getAnimal(animalId);
    expect(await animal.isLifeCycleOver).to.equal(true);

    const carcassId = transaction.value;
    const cascas = await contract.connect(slaughterer).getCarcass(carcassId);

    expect(await cascas.animalId).to.equal(animalId);
  });

  it("should not create carcas of already slaughtered animal", async function () {
    await contract.connect(slaughterer).slaughterAnimal(animalId);
    await expect(
      contract.connect(slaughterer).slaughterAnimal(animalId)
    ).to.be.revertedWith("Animal already has been slaughtered");
  });

  it("should set carcass data correctly", async function () {
    const transaction = await contract
      .connect(slaughterer)
      .slaughterAnimal(animalId);

    const animal = await contract.connect(slaughterer).getAnimal(animalId);
    expect(await animal.isLifeCycleOver).to.equal(true);

    const carcassId = transaction.value;

    const agreementNumber = "AG123";
    const countryOfSlaughter = "Country";
    const dateOfSlaughter = Math.floor(Date.now() / 1000);
    const carcassWeight = 100;
    const isContaminated = false;

    await contract
      .connect(slaughterer)
      .updateCarcass(
        carcassId,
        agreementNumber,
        countryOfSlaughter,
        dateOfSlaughter,
        carcassWeight,
        isContaminated
      );

    const carcassInfo = await contract
      .connect(slaughterer)
      .getCarcass(carcassId);

    expect(carcassInfo.agreementNumber).to.equal(agreementNumber);
    expect(carcassInfo.countryOfSlaughter).to.equal(countryOfSlaughter);
    expect(carcassInfo.dateOfSlaughter).to.equal(dateOfSlaughter);
    expect(carcassInfo.carcassWeight).to.equal(carcassWeight);
    expect(carcassInfo.animalId).to.equal(animalId);
  });

  it("should only be allowed for slaughteres to change the carcass data", async function () {
    const transaction = await contract
      .connect(slaughterer)
      .slaughterAnimal(animalId);

    const animal = await contract.connect(slaughterer).getAnimal(animalId);
    expect(await animal.isLifeCycleOver).to.equal(true);

    const carcassId = transaction.value;

    const agreementNumber = "AG123";
    const countryOfSlaughter = "Country";
    const dateOfSlaughter = Math.floor(Date.now() / 1000);
    const carcassWeight = 100;
    const isContaminated = false;

    await expect(
      contract
        .connect(breeder)
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

  it("should transfer carcass to transporter", async function () {
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
  });

  it("should not allow transfer carcass to other role than transporter", async function () {
    const transaction = await contract
      .connect(slaughterer)
      .slaughterAnimal(animalId);
    const carcassId = transaction.value;

    await expect(
      contract
        .connect(slaughterer)
        .transferCarcassToTransporter(carcassId, breeder.address)
    ).to.be.revertedWith("Caller is not valid receiver");
  });
});
