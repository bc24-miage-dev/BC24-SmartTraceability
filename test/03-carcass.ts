import { expect } from "chai";
import { SetupService } from "./setupService";

describe("BC24-Carcass", function () {
  let defaultAdmin:any;
  let minter: any;
  let transporter: any;
  let slaughterer: any;
  let breeder: any;
  let contract: any;
  let animalId: any;
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
    contract = setupService.contract;

    const transaction = await contract
      .connect(breeder)
      .createAnimal(breeder.address, "Cow", 10, "male");
    animalId = transaction.value;
    await contract
      .connect(breeder)
      .transferToken(animalId, transporter.address);
    await contract
      .connect(transporter)
      .transferToken(animalId, slaughterer.address);
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
