import { ethers, upgrades } from "hardhat";

export class SetupService {
  defaultAdmin: any;
  minter: any;
  transporter: any;
  slaughterer: any;
  breeder: any;
  random: any;
  contract: any;

  constructor() {
    this.defaultAdmin = {};
    this.minter = {};
    this.transporter = {};
    this.slaughterer = {};
    this.breeder = {};
    this.contract = {};
  }

  async setup() {
    /* Default wallets*/
    this.defaultAdmin = (await ethers.getSigners())[0];
    this.minter = (await ethers.getSigners())[1];
    this.breeder = (await ethers.getSigners())[2];
    this.transporter = (await ethers.getSigners())[3];
    this.slaughterer = (await ethers.getSigners())[4];
    this.random = (await ethers.getSigners())[5];

    /* Add interfaces here like below */
    const AnimalContract = await ethers.getContractFactory("AnimalData");
    const animalContract = await upgrades.deployProxy(AnimalContract, [
      this.defaultAdmin.address,
    ]);
    await animalContract.waitForDeployment();

    const CarcassContract = await ethers.getContractFactory("CarcassData");
    const carcassContract = await upgrades.deployProxy(CarcassContract, [
      this.defaultAdmin.address,
    ]);
    await carcassContract.waitForDeployment();


    const RecipeContract = await ethers.getContractFactory("RecipeData");
    const recipeContract = await upgrades.deployProxy(RecipeContract, [
      this.defaultAdmin.address,
    ]);
    await recipeContract.waitForDeployment();

    /* This is the main contract that takes all the addresses of the other contracst */
    const BC24Contract = await ethers.getContractFactory("BC24");
    this.contract = await upgrades.deployProxy(BC24Contract, [
      this.defaultAdmin.address,
      await animalContract.getAddress(),
      await carcassContract.getAddress(),
      await recipeContract.getAddress(),
      /* add new contract addresses here */
    ]);

    await this.contract.waitForDeployment();

    /* Grant roles */
    await this.contract
      .connect(this.defaultAdmin)
      .grantRoleToAddress(this.breeder.address, "BREEDER_ROLE");
    await this.contract
      .connect(this.defaultAdmin)
      .grantRoleToAddress(this.breeder.address, "MINTER_ROLE");

    await this.contract
      .connect(this.defaultAdmin)
      .grantRoleToAddress(this.transporter.address, "TRANSPORTER_ROLE");
    await this.contract
      .connect(this.defaultAdmin)
      .grantRoleToAddress(this.slaughterer.address, "SLAUGHTER_ROLE");
  }
}
