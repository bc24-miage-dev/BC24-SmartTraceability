import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";
import { SetupService } from "./setupService";

describe("BC24-Meat", function () {
  let defaultAdmin: any;
  let minter: any;
  let transporter: any;
  let slaughterer: any;
  let breeder: any;
  let manufacturer: any;
  let contract: any;
  let random: any;
  let animalId: any;
  let carcassId: any;

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
    manufacturer = setupService.manufacturer;
    contract = setupService.contract;

    const transaction = await contract
      .connect(breeder)
      .createAnimal(breeder.address, "Cow", 10, "male");
    animalId = transaction.value;
    await contract
      .connect(breeder)
      .transferToken(animalId, transporter.address);
    const slaugtherTransaction = await contract
      .connect(transporter)
      .transferToken(animalId, slaughterer.address);
    carcassId = slaugtherTransaction.value;
    await contract
      .connect(slaughterer)
      .transferToken(carcassId, transporter.address);
    await contract
      .connect(transporter)
      .transferToken(carcassId, manufacturer.address);
  });

  it("Test contract", async function () {
    expect(await contract.uri(0)).to.equal("");
    expect(await contract.connect(manufacturer).ownerOf(carcassId)).to.equal(
      manufacturer.address
    );
  });

  it("should create a new MeatNFT which is connected to the carcass", async function () {
    const transaction = await contract
      .connect(manufacturer)
      .createMeat(carcassId);

    const meatId = transaction.value;
    const cascass = await contract.connect(manufacturer).getMeat(meatId);

    expect(await cascass.carcassId).to.equal(carcassId);
  });

  it("update meat data", async function () {
    const transaction = await contract
      .connect(manufacturer)
      .createMeat(carcassId);

    const meatId = transaction.value;

    const agreementNumber = "1111";
    const countryOfCutting = "Schweiz";
    const dateOfCutting = 1622524800;
    const part = "Tongue";
    const isContaminated = false;
    const weight = 100;

    await expect(
      await contract
        .connect(manufacturer)
        .updateMeat(
          meatId,
          agreementNumber,
          countryOfCutting,
          dateOfCutting,
          part,
          isContaminated,
          weight
        )
    )
      .to.emit(contract, "MetaDataChanged")
      .withArgs(meatId, manufacturer.address, "Meat info changed.");

    const meat = await contract.connect(manufacturer).getMeat(meatId);
    expect(meat.agreementNumber).to.equal(agreementNumber);
    expect(meat.countryOfCutting).to.equal(countryOfCutting);
    expect(meat.dateOfCutting).to.equal(dateOfCutting);
  });

  it("Test ownershipcreate", async function () {
    expect(await contract.uri(0)).to.equal("");
    const transaction = await contract
      .connect(manufacturer)
      .createMeat(carcassId);
    const meatId = transaction.value;

    expect(await contract.connect(manufacturer).ownerOf(meatId)).to.equal(
      manufacturer.address
    );
  });

  it("create manufactured product", async function () {
    let meatIds: any[] = [];

    const transaction = await contract
      .connect(manufacturer)
      .createMeat(carcassId);

    const receipt = await transaction.wait();

    const transaction2 = await contract
      .connect(manufacturer)
      .createMeat(carcassId);

    const receipt2 = await transaction2.wait();

    const transaction3 = await contract
      .connect(manufacturer)
      .createMeat(carcassId);

    const receipt3 = await transaction3.wait();
    meatIds.push();

    meatIds.push(receipt.logs[1].args[0]);
    meatIds.push(receipt2.logs[1].args[0]);
    meatIds.push(receipt3.logs[1].args[0]);

    expect(
      await contract
        .connect(manufacturer)
        .createManufacturedProductData(meatIds)
    )
      .to.emit(contract, "NFTMinted")
      .withArgs(5n, manufacturer.address, "ManufacturedProduct created");
  });
});
