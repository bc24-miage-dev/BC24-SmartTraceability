import { ethers, upgrades } from "hardhat";

export class SetupService {
  defaultAdmin: any;
  minter: any;
  transporter: any;
  slaughterer: any;
  breeder: any;
  random: any;
  manufacturer: any;
  bc24: any;
  roleAccessContract: any;
  animalContract: any;
  carcassContract: any;
  transportContract: any;
  meatContract: any;
  recipeContract: any;
  manufacturedProductContract: any;
  ownerAndCategoryMapperContract: any;

  constructor() {
    this.defaultAdmin = {};
    this.minter = {};
    this.transporter = {};
    this.slaughterer = {};
    this.breeder = {};
    this.bc24 = {};
    this.random = {};
    this.manufacturer = {};
    this.animalContract = {};
    this.carcassContract = {};
    this.transportContract = {};
    this.meatContract = {};
    this.recipeContract = {};
    this.roleAccessContract = {};
    this.ownerAndCategoryMapperContract = {};
  }

  async setup() {
    /* Default wallets*/
    this.defaultAdmin = (await ethers.getSigners())[0];
    this.minter = (await ethers.getSigners())[1];
    this.breeder = (await ethers.getSigners())[2];
    this.transporter = (await ethers.getSigners())[3];
    this.slaughterer = (await ethers.getSigners())[4];
    this.random = (await ethers.getSigners())[5];
    this.manufacturer = (await ethers.getSigners())[6];

    /* Add interfaces here like below */

    const OwnerAndCategoryMapper = await ethers.getContractFactory(
      "OwnerAndCategoryMapper"
    );
    this.ownerAndCategoryMapperContract = await upgrades.deployProxy(
      OwnerAndCategoryMapper,
      [this.defaultAdmin.address]
    );
    await this.ownerAndCategoryMapperContract.waitForDeployment();

    const RoleAccess = await ethers.getContractFactory("RoleAccess");
    this.roleAccessContract = await upgrades.deployProxy(RoleAccess, [
      this.defaultAdmin.address,
    ]);
    await this.roleAccessContract.waitForDeployment();

    const TransportData = await ethers.getContractFactory("TransportData");
    this.transportContract = await upgrades.deployProxy(TransportData, [
      this.defaultAdmin.address,
      await this.roleAccessContract.getAddress(),
      await this.ownerAndCategoryMapperContract.getAddress(),
    ]);
    await this.transportContract.waitForDeployment();

    /* Add interfaces here like below */
    const AnimalContract = await ethers.getContractFactory("AnimalData");
    this.animalContract = await upgrades.deployProxy(AnimalContract, [
      this.defaultAdmin.address,
      await this.roleAccessContract.getAddress(),
      await this.ownerAndCategoryMapperContract.getAddress(),
    ]);

    await this.animalContract.waitForDeployment();

    const CarcassContract = await ethers.getContractFactory("CarcassData");
    this.carcassContract = await upgrades.deployProxy(CarcassContract, [
      this.defaultAdmin.address,
      await this.roleAccessContract.getAddress(),
      await this.ownerAndCategoryMapperContract.getAddress(),
    ]);
    await this.carcassContract.waitForDeployment();

    // Déploiement du contrat MeatData
    const MeatData = await ethers.getContractFactory("MeatData");
    this.meatContract = await upgrades.deployProxy(MeatData, [
      this.defaultAdmin.address,
      await this.roleAccessContract.getAddress(),
      await this.ownerAndCategoryMapperContract.getAddress(),
    ]);
    this.meatContract.waitForDeployment();

    const RecipeContract = await ethers.getContractFactory("RecipeData");
    this.recipeContract = await upgrades.deployProxy(RecipeContract, [
      this.defaultAdmin.address,
      await this.roleAccessContract.getAddress(),
      await this.ownerAndCategoryMapperContract.getAddress(),
    ]);
    this.recipeContract.waitForDeployment();

    const ManufacturedProductContract = await ethers.getContractFactory(
      "ManufacturedProductData"
    );
    this.manufacturedProductContract = await upgrades.deployProxy(
      ManufacturedProductContract,
      [
        this.defaultAdmin.address,
        await this.roleAccessContract.getAddress(),
        await this.ownerAndCategoryMapperContract.getAddress(),
      ]
    );
    await this.manufacturedProductContract.waitForDeployment();

    /* This is the main contract that takes all the addresses of the other contracst */
    const BC24Contract = await ethers.getContractFactory("BC24");
    this.bc24 = await upgrades.deployProxy(BC24Contract, [
      this.defaultAdmin.address,
      await this.animalContract.getAddress(),
      await this.carcassContract.getAddress(),
      await this.recipeContract.getAddress(),
      await this.meatContract.getAddress(),
      await this.transportContract.getAddress(),
      await this.manufacturedProductContract.getAddress(),
      await this.roleAccessContract.getAddress(),
      await this.ownerAndCategoryMapperContract.getAddress(),
    ]);

    await this.bc24.waitForDeployment();

    /* Grant roles */
    await this.roleAccessContract
      .connect(this.defaultAdmin)
      .grantRoleToAddress(this.breeder.address, "BREEDER_ROLE");
    await this.roleAccessContract
      .connect(this.defaultAdmin)
      .grantRoleToAddress(this.breeder.address, "MINTER_ROLE");
    await this.roleAccessContract
      .connect(this.defaultAdmin)
      .grantRoleToAddress(this.transporter.address, "TRANSPORTER_ROLE");
    await this.roleAccessContract
      .connect(this.defaultAdmin)
      .grantRoleToAddress(this.slaughterer.address, "SLAUGHTER_ROLE");
    await this.roleAccessContract
      .connect(this.defaultAdmin)
      .grantRoleToAddress(this.manufacturer.address, "MANUFACTURERE_ROLE");
  }
}
