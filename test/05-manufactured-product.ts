

import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";
import { SetupService } from "./setupService";

describe("BC24-Manufactured-Product", function () {
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

it("update manufacturedproduct data", async function () {
    const transaction = await contract
      .connect(manufacturer)
      .createMeat(carcassId);

    const meatId = transaction.value;

    const productTranscation = await contract
      .connect(manufacturer)
      .createManufacturedProduct(meatId);
    const manufacturedProductId = productTranscation.value;

    const productName = "Schnitzel";
    const dateOfManufacturation = 1622524800;
    const price = 50;
    const description = "Schnitzel aus der Schweiz";

    await expect(
      await contract
        .connect(manufacturer)
        .updateManufacturedProduct(
          manufacturedProductId,
          dateOfManufacturation,
          productName,
          price,
          description
        )
    )
      .to.emit(contract, "MetaDataChanged")
      .withArgs("ManufacturedProduct info added successfully.");

    const manufacturedProduct = await contract
      .connect(manufacturer)
      .getManufacturedProduct(manufacturedProductId);
    expect(manufacturedProduct.productName).to.equal(productName);
    expect(manufacturedProduct.dateOfManufacturation).to.equal(
      dateOfManufacturation
    );
  });

  it("create new recipe", async function () {
    expect(0).to.equal(1);
  });

  it("create new manufacturedProduct with recipe", async function () {
    expect(0).to.equal(1);
  });