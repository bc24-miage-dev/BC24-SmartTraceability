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
  let animalId: any;
  let carcassId: any;
  let transportId: any;

  let animalContract: any;
  let roleAccessContract: any;
  let ownerAndCategoryMapperContract: any;
  let transportContract: any;
  let carcassContract: any;
  let meatContract: any;

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
    manufacturer = setupService.manufacturer;
    animalContract = setupService.animalContract;
    roleAccessContract = setupService.roleAccessContract;
    ownerAndCategoryMapperContract =
      setupService.ownerAndCategoryMapperContract;
    transportContract = setupService.transportContract;
    carcassContract = setupService.carcassContract;
    meatContract = setupService.meatContract;

    const transaction = await animalContract
      .connect(breeder)
      .createAnimalData("Cow", 10, "male");
    const receipt = await transaction.wait();
    animalId = receipt.logs[1].args[0];

    /* Breeder --> Transporter */
    await animalContract
      .connect(breeder)
      .transferAnimal(animalId, transporter.address);

    /* Transporter --> Slaughterer */
    await animalContract
      .connect(transporter)
      .transferAnimal(animalId, slaughterer.address);

    /* Kill Animal */
    await animalContract.connect(slaughterer).killAnimal(animalId);

    /* Create Carcass */
    const transaction2 = await carcassContract
      .connect(slaughterer)
      .createCarcassData(animalId);
    const receipt2 = await transaction2.wait();
    carcassId = receipt2.logs[1].args[0];

    /* Carcass --> Transporter */
    await carcassContract
      .connect(slaughterer)
      .transferCarcass(carcassId, transporter.address);

    /* Transporter --> Manufacturer */
    await carcassContract
      .connect(transporter)
      .transferCarcass(carcassId, manufacturer.address);
  });

  it("Test contract", async function () {
    expect(
      await ownerAndCategoryMapperContract
        .connect(manufacturer)
        .getOwnerOfToken(carcassId)
    ).to.equal(manufacturer.address);
  });

  it("should create a new MeatNFT which is connected to the carcass", async function () {
    const MeatTransaction = await meatContract
      .connect(manufacturer)
      .createMeatData(carcassId, "MeatPartA", 100);

    const receipt = await MeatTransaction.wait();
    const meatId = receipt.logs[1].args[0];

    const meat = await meatContract.connect(manufacturer).getMeatData(meatId);

    expect(await meat.carcassId).to.equal(carcassId);
    expect(await meat.part).to.equal("MeatPartA");
    expect(await meat.weight).to.equal(100);
  });

  it("Test ownership after create", async function () {
    const MeatTransaction = await meatContract
      .connect(manufacturer)
      .createMeatData(carcassId, "MeatPartA", 100);

    const receipt = await MeatTransaction.wait();
    const meatId = receipt.logs[1].args[0];

    expect(
      await ownerAndCategoryMapperContract
        .connect(manufacturer)
        .getOwnerOfToken(meatId)
    ).to.equal(manufacturer.address);
  });

  it("update meat data", async function () {
    const MeatTransaction = await meatContract
      .connect(manufacturer)
      .createMeatData(carcassId, "MeatPartA", 100);

    const receipt = await MeatTransaction.wait();
    const meatId = receipt.logs[1].args[0];

    const agreementNumber = "1111";
    const countryOfCutting = "Schweiz";
    const dateOfCutting = 1622524800;
    const part = "Tongue";
    const isContaminated = false;
    const weight = 100;

    await expect(
      meatContract
        .connect(manufacturer)
        .setMeatData(
          meatId,
          agreementNumber,
          countryOfCutting,
          dateOfCutting,
          part,
          isContaminated,
          weight
        )
    )
      .to.emit(meatContract, "MetaDataChanged")
      .withArgs(meatId, manufacturer.address, "Meat info changed.");

    const meat = await meatContract.connect(manufacturer).getMeatData(meatId);
    expect(meat.agreementNumber).to.equal(agreementNumber);
    expect(meat.countryOfCutting).to.equal(countryOfCutting);
    expect(meat.dateOfCutting).to.equal(dateOfCutting);
  });
});
