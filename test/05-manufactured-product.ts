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
  let animalId: any;
  let carcassId: any;
  let transportId: any;
  let recipeId: any;
  let meatId: any;
  let meatId2: any;

  let bc24: any;
  let animalContract: any;
  let roleAccessContract: any;
  let ownerAndCategoryMapperContract: any;
  let transportContract: any;
  let carcassContract: any;
  let meatContract: any;
  let manufacturedProductContract: any;
  let recipeContract: any;

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
    manufacturedProductContract = setupService.manufacturedProductContract;
    recipeContract = setupService.recipeContract;

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
    const carcassTransaction = await carcassContract
      .connect(slaughterer)
      .createCarcassData(animalId);
    const carcassTransactionReceit = await carcassTransaction.wait();
    carcassId = carcassTransactionReceit.logs[1].args[0];

    /* Carcass --> Transporter */
    await carcassContract
      .connect(slaughterer)
      .transferCarcass(carcassId, transporter.address);

    /* Transporter --> Manufacturer */
    await carcassContract
      .connect(transporter)
      .transferCarcass(carcassId, manufacturer.address);

    const MeatTransaction1 = await meatContract
      .connect(manufacturer)
      .createMeatData(carcassId, "MeatPartA", 100);

    const MeatTransaction1Receit = await MeatTransaction1.wait();
    meatId = MeatTransaction1Receit.logs[1].args[0];

    const agreementNumber = "1111";
    const countryOfCutting = "Schweiz";
    const dateOfCutting = 1622524800;
    const part = "Tongue";
    const isContaminated = false;
    const weight = 100;

    await meatContract
      .connect(manufacturer)
      .setMeatData(
        meatId,
        agreementNumber,
        countryOfCutting,
        dateOfCutting,
        part,
        isContaminated,
        weight
      );
    const MeatTransaction2 = await meatContract
      .connect(manufacturer)
      .createMeatData(carcassId, "MeatPartA", 100);

    const MeatTransaction2Receit = await MeatTransaction2.wait();
    meatId2 = MeatTransaction2Receit.logs[1].args[0];

    await meatContract
      .connect(manufacturer)
      .setMeatData(
        meatId2,
        "2222",
        countryOfCutting,
        dateOfCutting,
        "Ribeye",
        isContaminated,
        weight
      );

    const recipeName: string = "Rindfleischsuppe";
    const description: string = "Rindfleischsuppe mit Gemüse";
    // These need to allign with the meat parts
    const ingredientMeat: string[] = ["Cow", "Cow"];
    const ingredientPart: string[] = ["Tongue", "Eye"];
    const ingredientWeight: number[] = [100, 100];

    const recepiTransaction = await recipeContract
      .connect(manufacturer)
      .createRecipeData(recipeName, description, ingredientMeat, ingredientPart, ingredientWeight);

    const recipeReceit = await recepiTransaction.wait();

    recipeId = recipeReceit.logs[1].args[0];
  });

  it("Test ownershipcreate", async function () {
    // expect(await contract.uri(0)).to.equal("");
    const transaction = await carcassContract
      .connect(manufacturer)
      .createMeat(carcassId);
    // const meatId = transaction.value;
    const receipt = await transaction.wait();
    const meatId = receipt.logs[1].args[0];

    expect(
      await ownerAndCategoryMapperContract.connect(manufacturer).getOwnerOfToken(meatId)
    ).to.equal(manufacturer.address);
  });

  it("create manufacturedproduct data", async function () {
    const manufacturedProductTransaction = await manufacturedProductContract
      .connect(manufacturer)
      .createManufacturedProductData(0, [meatId], "Test", 500, "test");

    const receipt = await manufacturedProductTransaction.wait();
    expect(receipt.logs[1].args[0]).to.equal(5);
    expect(receipt.logs[1].args[1]).to.equal(manufacturer.address);
    expect(receipt.logs[1].args[2]).to.equal("ManufacturedProduct created");
  });

  it("update manufacturedproduct data", async function () {
    const productTranscation = await manufacturedProductContract
      .connect(manufacturer)
      .createManufacturedProductData(0, [meatId], "Test", 500, "test");

    const receipt = await productTranscation.wait();
    const manufacturedProductId = receipt.logs[1].args[0];

    const productName = "Schnitzel";
    const dateOfManufacturation = 1622524800;
    const price = 50;
    const description = "Schnitzel aus der Schweiz";

    await contract
      .connect(manufacturer)
      .updateManufacturedProduct(
        manufacturedProductId,
        dateOfManufacturation,
        productName,
        price,
        description
      );

    const manufacturedProduct = await manufacturedProductContract
      .connect(manufacturer)
      .getManufacturedProduct(manufacturedProductId);

    expect(manufacturedProduct.productName).to.equal(productName);
    expect(manufacturedProduct.dateOfManufacturation).to.equal(
      dateOfManufacturation
    );
  });

  it("should show that meat is part of recipe", async function () {
    const checkIMeat = await manufacturedProductContract
      .connect(manufacturer)
      .checkIfMeatCanBeUsedForRecipe(recipeId, meatId);

    expect(checkIMeat).to.equal(true);
  });

  it("should show that meat is not part of recipe", async function () {
    const checkIMeat = await manufacturedProductContract
      .connect(manufacturer)
      .checkIfMeatCanBeUsedForRecipe(recipeId, meatId2);

    expect(checkIMeat).to.equal(false);
  });

  it("should not allow to create manufacturedProduct with recipe if wrong meat is present", async function () {
    await expect(
      manufacturedProductContract
        .connect(manufacturer)
        .createManufacturedProductData(recipeId, [meatId, meatId2], "", 50, "")
    ).to.be.revertedWith("Meat is not valid for the recipe");
  });

  it("should not allow to create manufacturedProduct with recipe if not all meat is present", async function () {
    await expect(
      manufacturedProductContract
        .connect(manufacturer)
        .createManufacturedProductData(recipeId, [meatId2], "", 50, "")
    ).to.be.revertedWith("Meat is not valid for the recipe");
  });

  it("should allow to create manufacturedProduct with recipe ", async function () {
    const agreementNumber = "2222";
    const countryOfCutting = "Schweiz";
    const dateOfCutting = 1622524800;
    const part = "Eye";
    const isContaminated = false;
    const weight = 100;

    await manufacturedProductContract
      .connect(manufacturer)
      .updateMeat(
        meatId2,
        agreementNumber,
        countryOfCutting,
        dateOfCutting,
        part,
        isContaminated,
        weight
      );

    const productTranscation = await manufacturedProductContract
      .connect(manufacturer)
      .createManufacturedProductData(recipeId, [meatId, meatId2], "", 50, "");

    const productReceit = await productTranscation.wait();

    const getManufacturedProduct = await manufacturedProductContract
      .connect(manufacturer)
      .getManufacturedProduct(productReceit.logs[1].args[0]);

    expect(getManufacturedProduct.price).to.equal(50);
    expect(getManufacturedProduct.meatIds[0]).to.equal(meatId);
    expect(getManufacturedProduct.meatIds[1]).to.equal(meatId2);
  });
});
