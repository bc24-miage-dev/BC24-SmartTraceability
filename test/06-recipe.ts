import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";
import { SetupService } from "./setupService";

describe("BC24-Recipe", function () {
  let defaultAdmin: any;
  let minter: any;
  let transporter: any;
  let slaughterer: any;
  let breeder: any;
  let manufacturer: any;
  let contract: any;
  let animalId: any;
  let carcassId: any;

  let bc24: any;
  let animalContract: any;
  let roleAccessContract: any;
  let ownerAndCategoryMapperContract: any;
  let transportContract: any;
  let carcassContract: any;
  let meatContract: any;
  let recipeContract: any;

  let setupService: any;

  beforeEach(async function () {
    setupService = new SetupService();
    await setupService.setup();

    defaultAdmin = setupService.defaultAdmin;
    minter = setupService.minter;
    breeder = setupService.breeder;
    transporter = setupService.transporter;
    slaughterer = setupService.slaughterer;
    manufacturer = setupService.manufacturer;
    bc24 = setupService.bc24;
    animalContract = setupService.animalContract;
    roleAccessContract = setupService.roleAccessContract;
    ownerAndCategoryMapperContract =
      setupService.ownerAndCategoryMapperContract;
    transportContract = setupService.transportContract;
    carcassContract = setupService.carcassContract;
    meatContract = setupService.meatContract;
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
    const meatId = MeatTransaction1Receit.logs[1].args[0];

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
    const meatId2 = MeatTransaction2Receit.logs[1].args[0];

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
  });

  it("Test contract", async function () {
    expect(await recipeContract.uri(0)).to.equal("");
  });

  it("should create a new recipe", async function () {
    const recipeName: string = "Rindfleischsuppe";
    const description: string = "Rindfleischsuppe mit Gemüse";
    // These need to allign with the meat parts
    const ingredientMeat: string[] = ["Cow", "Cow"];
    const ingredientPart: string[] = ["Tongue", "eye"];
    const ingredientWeight: number[] = [100, 100];

    const recipeTransaction = await recipeContract
      .connect(manufacturer)
      .createRecipeData(
        recipeName,
        description,
        ingredientMeat,
        ingredientPart,
        ingredientWeight
      );

    const recipeTransactionReceit = await recipeTransaction.wait();
    const recipeId = recipeTransactionReceit.logs[1].args[0];

    const recipe = await recipeContract
      .connect(manufacturer)
      .getRecipeData(recipeId);

    expect(await recipe.recipeName).to.equal(recipeName);
    expect(await recipe.description).to.equal(description);
    expect(await recipe.ingredient[0].animalType).to.equal(
      ingredientMeat[0]
    );
    expect(await recipe.ingredient[1].animalType).to.equal(
      ingredientMeat[1]
    );

    expect(await recipe.ingredient[0].part).to.equal(ingredientPart[0]);
    expect(await recipe.ingredient[1].part).to.equal(ingredientPart[1]);

    expect(await recipe.ingredient[0].weight).to.equal(ingredientWeight[0]);
    expect(await recipe.ingredient[1].weight).to.equal(ingredientWeight[1]);
  });
});
