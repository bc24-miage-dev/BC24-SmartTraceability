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
  let meatId: any;
  let meatId2: any;
  let recipeId: any;

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

    const receipt = await transaction.wait();

    animalId = receipt.logs[1].args[0];

    await contract
      .connect(breeder)
      .transferToken(animalId, transporter.address);
    await contract
      .connect(transporter)
      .transferToken(animalId, slaughterer.address);

    const slaugtherTransaction = await contract
      .connect(slaughterer)
      .slaughterAnimal(animalId);
    const receiptSlaughter = await slaugtherTransaction.wait();
    carcassId = receiptSlaughter.logs[1].args[0];

    await contract
      .connect(slaughterer)
      .transferToken(carcassId, transporter.address);
    await contract
      .connect(transporter)
      .transferToken(carcassId, manufacturer.address);

    const meatTransaction = await contract
      .connect(manufacturer)
      .createMeat(carcassId);

    const meatTransactionReceit = await meatTransaction.wait();

    meatId = meatTransactionReceit.logs[1].args[0];

    const agreementNumber = "1111";
    const countryOfCutting = "Schweiz";
    const dateOfCutting = 1622524800;
    const part = "Tongue";
    const isContaminated = false;
    const weight = 100;

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
      );

    const transaction2 = await contract
      .connect(manufacturer)
      .createMeat(carcassId);

    const receipt2 = await transaction2.wait();

    meatId2 = receipt2.logs[1].args[0];

    await contract
      .connect(manufacturer)
      .updateMeat(
        meatId2,
        "2222",
        countryOfCutting,
        dateOfCutting,
        "eye",
        isContaminated,
        weight
      );

    const recipeName: string = "Rindfleischsuppe";
    const description: string = "Rindfleischsuppe mit Gemüse";
    // These need to allign with the meat parts
    const ingredientMeat: string[] = ["Cow", "Cow"];
    const ingredientPart: string[] = ["Tongue", "eye"];

    const recepiTransaction = await contract
      .connect(manufacturer)
      .createRecipe(recipeName, description, ingredientMeat, ingredientPart);

    const recipeReceit = await recepiTransaction.wait();

    recipeId = recipeReceit.logs[1].args[0];
  });

  it("Test ownershipcreate", async function () {
    // expect(await contract.uri(0)).to.equal("");
    const transaction = await contract
      .connect(manufacturer)
      .createMeat(carcassId);
    // const meatId = transaction.value;
    const receipt = await transaction.wait();
    const meatId = receipt.logs[1].args[0];

    expect(await contract.connect(manufacturer).ownerOf(meatId)).to.equal(
      manufacturer.address
    );
  });

  it("create manufacturedproduct data", async function () {
    const manufacturedProductTransaction = await contract
      .connect(manufacturer)
      .createManufacturedProductData(0, [meatId], "Test", 500, "test");

    const receipt = await manufacturedProductTransaction.wait();
    expect(receipt.logs[1].args[0]).to.equal(5);
    expect(receipt.logs[1].args[1]).to.equal(manufacturer.address);
    expect(receipt.logs[1].args[2]).to.equal("ManufacturedProduct created");
  });

  it("update manufacturedproduct data", async function () {
    const productTranscation = await contract
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

    const manufacturedProduct = await contract
      .connect(manufacturer)
      .getManufacturedProduct(manufacturedProductId);

    expect(manufacturedProduct.productName).to.equal(productName);
    expect(manufacturedProduct.dateOfManufacturation).to.equal(
      dateOfManufacturation
    );
  });

  it("create new manufacturedProduct with recipe", async function () {
    const productTranscation = await contract
      .connect(manufacturer)
      .createManufacturedProductData(recipeId, [meatId, meatId2], "", 50, "");

    const productReceit = await productTranscation.wait();

    const getManufacturedProduct = await contract
      .connect(manufacturer)
      .getManufacturedProduct(productReceit.logs[1].args[0]);

    expect(getManufacturedProduct.price).to.equal(50);
    expect(getManufacturedProduct.meatIds[0]).to.equal(meatId);
    expect(getManufacturedProduct.meatIds[1]).to.equal(meatId2);
  });
});
