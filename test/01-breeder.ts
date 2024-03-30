import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";

describe("BC24-Breeder", function () {
  let defaultAdmin: { address: unknown; };
  let minter: { address: unknown; };
  let random: any;
  let breeder: any;
  let transporter: any;
  let contract: any;

  beforeEach(async function () {
    const ContractFactory = await ethers.getContractFactory("BC24");
    defaultAdmin = (await ethers.getSigners())[0];
    minter = (await ethers.getSigners())[1];
    random = (await ethers.getSigners())[2];
    breeder = (await ethers.getSigners())[3];
    transporter = (await ethers.getSigners())[4];

    contract = await upgrades.deployProxy(ContractFactory, [
      defaultAdmin.address
      /*       minter.address,
            defaultAdmin.address,
            defaultAdmin.address, */
    ]);

    await contract.waitForDeployment();

    // grant the roles
    await contract.connect(defaultAdmin).grantRoleToAddress(minter.address, "MINTER_ROLE");

    await contract.connect(defaultAdmin).grantRoleToAddress(breeder.address, "BREEDER_ROLE");
    await contract.connect(defaultAdmin).grantRoleToAddress(breeder.address, "MINTER_ROLE");

    await contract.connect(defaultAdmin).grantRoleToAddress(transporter.address, "TRANSPORTER_ROLE");



  });

  it("Test contract", async function () {
    expect(await contract.uri(0)).to.equal("");
  })

  it("should allow the breeder role to create animal", async function () {
    await expect(await contract.connect(breeder).createAnimal(breeder.address))
      .to.emit(contract, "AnimalNFTMinted")
      .withArgs(0);

    const indexAfterMint = await contract.getTokenIndex();
    expect(indexAfterMint).to.equal(1);
  });

  it("should throw when others than breeder try to create animal", async function () {
    await expect(
      contract.connect(defaultAdmin).createAnimal(defaultAdmin.address)
    ).to.be.revertedWith("Caller is not a breeder");
  });

  it("should mint animal and increment _nextTokenId", async function () {
    await expect(contract.connect(breeder).createAnimal(breeder.address))
      .to.emit(contract, "AnimalNFTMinted")
      .withArgs(0);

    await expect(contract.connect(breeder).createAnimal(breeder.address))
      .to.emit(contract, "AnimalNFTMinted")
      .withArgs(1);

    const indexAfterMint = await contract.getTokenIndex();
    expect(indexAfterMint).to.equal(2);
  });

  it("should create an animal successfully", async () => {
    await contract.connect(breeder).createAnimal(breeder.address);

    // Create some sample data
    const placeOfOrigin = "Farm XYZ";
    const dateOfBirth = 1622524800; // June 1, 2021
    const gender = "Male";
    const weight = 1000;
    const sicknessList: [] = []; // Empty list
    const vaccinationList: [] = []; // Empty list
    const foodList: [] = []; // Empty lis


    await expect(await contract.connect(breeder).updateAnimal(0, placeOfOrigin, dateOfBirth, gender, weight, sicknessList, vaccinationList, foodList)
    )
      .to.emit(contract, "MetaDataChanged")
      .withArgs("Breeding info added successfully.");

    const animalData = await contract.connect(breeder).getAnimal(0);
    expect(animalData.placeOfOrigin).to.equal(placeOfOrigin);
    expect(animalData.dateOfBirth).to.equal(dateOfBirth);
    expect(animalData.gender).to.equal(gender);
    expect(animalData.weight).to.equal(weight);
    expect(animalData.sicknessList).to.deep.equal(sicknessList);
    expect(animalData.vaccinationList).to.deep.equal(vaccinationList);
    expect(animalData.foodList).to.deep.equal(foodList);

  });
  it("should not be able to set animalData of another breeder", async () => {
    await contract.connect(breeder).createAnimal(breeder.address);

    // Create some sample data
    const placeOfOrigin = "Farm XYZ";
    const dateOfBirth = 1622524800; // June 1, 2021
    const gender = "Male";
    const weight = 1000;
    const sicknessList: [] = []; // Empty list
    const vaccinationList: [] = []; // Empty list
    const foodList: [] = []; // Empty lis

    await contract.connect(defaultAdmin).grantRoleToAddress(random.address, "BREEDER_ROLE");

    await expect(contract.connect(random).updateAnimal(0, placeOfOrigin, dateOfBirth, gender, weight, sicknessList, vaccinationList, foodList)
    ).to.be.revertedWith("Caller does not own this token")
  });

  it("should transfer animal to transporter", async function () {
    await contract.connect(breeder).createAnimal(breeder.address);

    await expect(contract.connect(transporter).getAnimal(0)
    ).to.be.revertedWith("Caller does not own this token")

    await contract.connect(breeder).transferAnimalToTransporter(0, transporter.address);

    await expect(contract.connect(breeder).getAnimal(0)
    ).to.be.revertedWith("Caller does not own this token")

    expect(await contract.connect(transporter).ownerOf(0)).to.equal(transporter.address);
  });

});
