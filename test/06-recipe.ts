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
    const meat1 = await contract.connect(manufacturer).createMeat(carcassId);
    const meat1Token = meat1.value;

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
          meat1Token,
          agreementNumber,
          countryOfCutting,
          dateOfCutting,
          part,
          isContaminated,
          weight
        )
    );

    const meat2 = await contract.connect(manufacturer).createMeat(carcassId);
    const meat2Token = meat2.value;

    const agreementNumber2 = "2222";
    const countryOfCutting2 = "Schweiz";
    const dateOfCutting2 = 1622524800;
    const part2 = "eye";
    const isContaminated2 = false;
    const weight2 = 100;

    await expect(
      await contract
        .connect(manufacturer)
        .updateMeat(
          meat2Token,
          agreementNumber2,
          countryOfCutting2,
          dateOfCutting2,
          part2,
          isContaminated2,
          weight2
        )
    );
  });

  it("Test contract", async function () {
    expect(await contract.uri(0)).to.equal("");
  });

  it("should create a new recipe", async function () {
    let recipeId = 0;
    contract.on("NFTMinted", (tokenId, sender, message) => {
      recipeId = tokenId;
    });

    const recipeName: string = "Rindfleischsuppe";
    const description: string = "Rindfleischsuppe mit Gemüse";
    // These need to allign with the meat parts
    const ingredientMeat: string[] = ["Cow", "Cow"];
    const ingredientPart: string[] = ["Tongue", "eye"];

    const transaction = await contract
      .connect(manufacturer)
      .createRecipe(recipeName, description, ingredientMeat, ingredientPart);

    const receipt = await transaction.wait();

    const recipe = await contract.connect(manufacturer).getRecipe(recipeId);

    expect(await recipe.recipeName).to.equal(recipeName);
    expect(await recipe.description).to.equal(description);
    expect(await recipe.ingredientMeat[0].animalType).to.equal(ingredientMeat[0]);
    expect(await recipe.ingredientMeat[1].animalType).to.equal(ingredientMeat[1]);
    expect(await recipe.ingredientMeat[0].part).to.equal(ingredientPart[0]);
    expect(await recipe.ingredientMeat[1].part).to.equal(ingredientPart[1]);
  });
});
