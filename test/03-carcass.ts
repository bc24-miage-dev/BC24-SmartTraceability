import { expect } from "chai";
import { SetupService } from "./setupService";

describe("BC24-Carcass", function () {
  let defaultAdmin: any;
  let minter: any;
  let transporter: any;
  let slaughterer: any;
  let breeder: any;
  let animalId: any;
  let transportId: any;

  let animalContract: any;
  let roleAccessContract: any;
  let ownerAndCategoryMapperContract: any;
  let transportContract: any;
  let carcassContract: any;

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
    animalContract = setupService.animalContract;
    roleAccessContract = setupService.roleAccessContract;
    ownerAndCategoryMapperContract =
      setupService.ownerAndCategoryMapperContract;
    transportContract = setupService.transportContract;
    carcassContract = setupService.carcassContract;

    const transaction = await animalContract
      .connect(breeder)
      .createAnimalData("Cow", 10, "male");
    const receipt = await transaction.wait();
    animalId = receipt.logs[1].args[0];
    await animalContract
      .connect(breeder)
      .transferAnimal(animalId, transporter.address);

    await animalContract
      .connect(transporter)
      .transferAnimal(animalId, slaughterer.address);
  });

  it("Test contract", async function () {
    expect(
      await ownerAndCategoryMapperContract
        .connect(slaughterer)
        .getOwnerOfToken(animalId)
    ).to.equal(slaughterer.address);
  });

  it("should make sure the animal is still alive", async function () {
    const animal = await animalContract
      .connect(slaughterer)
      .getAnimalData(animalId);
    expect(await animal.isLifeCycleOver).to.equal(false);
  });

  it("should create a new carcassNFT which is connected to the now dead animal", async function () {
    const transaction = await animalContract
      .connect(slaughterer)
      .killAnimal(animalId);

    // create carcass data first

    const carcassTransaction = await carcassContract
      .connect(slaughterer)
      .createCarcassData(animalId);

    const carcassTransactionReceipt = await carcassTransaction.wait();
    const carcassId = carcassTransactionReceipt.logs[1].args[0];

    const animal = await animalContract
      .connect(slaughterer)
      .getAnimalData(animalId);
    expect(await animal.isLifeCycleOver).to.equal(true);

    const cascass = await carcassContract
      .connect(slaughterer)
      .getCarcassData(carcassId);

    expect(await cascass.animalId).to.equal(animalId);
  });

  it("should not create carcas of already slaughtered animal", async function () {
    await animalContract.connect(slaughterer).killAnimal(animalId);
    await expect(
      animalContract.connect(slaughterer).killAnimal(animalId)
    ).to.be.revertedWith("Animal already has been slaughtered");
  });

  it("should set carcass data correctly", async function () {
    await animalContract.connect(slaughterer).killAnimal(animalId);

    const carcassTransaction = await carcassContract
      .connect(slaughterer)
      .createCarcassData(animalId);

    const carcassTransactionReceipt = await carcassTransaction.wait();
    const carcassId = carcassTransactionReceipt.logs[1].args[0];

    const animal = await animalContract
      .connect(slaughterer)
      .getAnimalData(animalId);
    expect(await animal.isLifeCycleOver).to.equal(true);

    const agreementNumber = "AG123";
    const countryOfSlaughter = "Country";
    const dateOfSlaughter = Math.floor(Date.now() / 1000);
    const carcassWeight = 100;
    const isContaminated = false;

    await carcassContract
      .connect(slaughterer)
      .setCarcassData(
        carcassId,
        agreementNumber,
        countryOfSlaughter,
        dateOfSlaughter,
        carcassWeight,
        isContaminated
      );

    const carcassInfo = await carcassContract
      .connect(slaughterer)
      .getCarcassData(carcassId);

    expect(carcassInfo.agreementNumber).to.equal(agreementNumber);
    expect(carcassInfo.countryOfSlaughter).to.equal(countryOfSlaughter);
    expect(carcassInfo.dateOfSlaughter).to.equal(dateOfSlaughter);
    expect(carcassInfo.carcassWeight).to.equal(carcassWeight);
    expect(carcassInfo.animalId).to.equal(animalId);
  });

  it("should only be allowed for slaughteres to change the carcass data", async function () {
    const transaction = await animalContract
      .connect(slaughterer)
      .killAnimal(animalId);

    const carcassTransaction = await carcassContract
      .connect(slaughterer)
      .createCarcassData(animalId);

    const carcassTransactionReceipt = await carcassTransaction.wait();
    const carcassId = carcassTransactionReceipt.logs[1].args[0];

    const animal = await animalContract
      .connect(slaughterer)
      .getAnimalData(animalId);
    expect(await animal.isLifeCycleOver).to.equal(true);

    const agreementNumber = "AG123";
    const countryOfSlaughter = "Country";
    const dateOfSlaughter = Math.floor(Date.now() / 1000);
    const carcassWeight = 100;
    const isContaminated = false;

    await expect(
      carcassContract
        .connect(breeder)
        .setCarcassData(
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
    await animalContract.connect(slaughterer).killAnimal(animalId);

    const carcassTransaction = await carcassContract
      .connect(slaughterer)
      .createCarcassData(animalId);

    const carcassTransactionReceipt = await carcassTransaction.wait();
    const carcassId = carcassTransactionReceipt.logs[1].args[0];

    await carcassContract
      .connect(slaughterer)
      .transferCarcass(carcassId, transporter.address); ////todo fonction qui transfer que si bc pas impl, receiverOnlyRole not used

    expect(
      await ownerAndCategoryMapperContract
        .connect(transporter)
        .getOwnerOfToken(carcassId)
    ).to.equal(transporter.address);
  });

  it("should not allow transfer carcass to other role than transporter", async function () {
    const transaction = await animalContract
      .connect(slaughterer)
      .killAnimal(animalId);

    const carcassTransaction = await carcassContract
      .connect(slaughterer)
      .createCarcassData(animalId);

    const carcassTransactionReceipt = await carcassTransaction.wait();
    const carcassId = carcassTransactionReceipt.logs[1].args[0];

    await expect(
      carcassContract
        .connect(slaughterer)
        .transferCarcass(carcassId, breeder.address) //todo fonction qui transfer que si bc pas impl, receiverOnlyRole not used
    ).to.be.revertedWith("Receiver is neither a transporter nor a manufacturer");
  });
});
