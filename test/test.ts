import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";

describe("BC24", function () {
  let defaultAdmin: { address: unknown; };
  let minter: { address: unknown; };
  let random: any;
  let breeder: any;

  let contract: any;

  beforeEach(async function () {
    const ContractFactory = await ethers.getContractFactory("BC24");
    defaultAdmin = (await ethers.getSigners())[0];
    minter = (await ethers.getSigners())[1];
    random = (await ethers.getSigners())[2];
    breeder = (await ethers.getSigners())[3];

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

  });

  it("Test contract", async function () {
    expect(await contract.uri(0)).to.equal("");
  })

  it("should only let default admin assign roles", async function () {
    expect(contract.connect(minter).grantRoleToAddress(minter.address, "MINTER_ROLE")).Throw;
    expect(contract.connect(breeder).grantRoleToAddress(minter.address, "MINTER_ROLE")).Throw;
  });

  it("should assign MINTER_ROLE role to an address", async function () {
    const tx = await contract.connect(defaultAdmin).grantRoleToAddress(random.address, "MINTER_ROLE");
    const receipt = await tx.wait();
    const RoleGrantedEvent = contract.filters.RoleGranted(null, null, null);
    const events = await contract.queryFilter(RoleGrantedEvent, receipt.blockNumber, receipt.blockNumber);
    assert.equal(events.length, 1, "Should have emitted one RoleGranted event");
    const eventArgs = events[0].args;
    assert.equal(eventArgs.account, random.address, "Should have correct minter address");
  });


  it("should allow the breeder role to create animal", async function () {
    await expect(contract.connect(breeder).createAnimalNFT(breeder.address))
      .to.emit(contract, "AnimalNFTMinted")
      .withArgs(0);

    const indexAfterMint = await contract.getTokenIndex();
    expect(indexAfterMint).to.equal(1);
  });

  it("should throw when others than minters try to create tokens", async function () {
    expect(
      contract.connect(defaultAdmin).createAnimalNFT(defaultAdmin.address)
    ).Throw;
  });

  it("should mint animalNFT and increment _nextTokenId", async function () {
    await expect(contract.connect(breeder).createAnimalNFT(breeder.address))
      .to.emit(contract, "AnimalNFTMinted")
      .withArgs(0);

    await expect(contract.connect(breeder).createAnimalNFT(breeder.address))
      .to.emit(contract, "AnimalNFTMinted")
      .withArgs(1);

    const indexAfterMint = await contract.getTokenIndex();
    expect(indexAfterMint).to.equal(2);
  });

  it("should create an animalNFT successfully", async () => {
    await contract.connect(breeder).createAnimalNFT(breeder.address);

    // Create some sample data
    const placeOfOrigin = "Farm XYZ";
    const dateOfBirth = 1622524800; // June 1, 2021
    const gender = "Male";
    const weight = 1000;
    const sicknessList: [] = []; // Empty list
    const vaccinationList: [] = []; // Empty list
    const foodList: [] = []; // Empty lis


    await expect(contract.connect(breeder).setBreederInfo(0, placeOfOrigin, dateOfBirth, gender, weight, sicknessList, vaccinationList, foodList)
    )
      .to.emit(contract, "MetaDataChanged")
      .withArgs("Breeding info added successfully.");

    const animalData = await contract.getBreederInfo(0);
    expect(animalData.placeOfOrigin).to.equal(placeOfOrigin);
    expect(animalData.dateOfBirth).to.equal(dateOfBirth);
    expect(animalData.gender).to.equal(gender);
    expect(animalData.weight).to.equal(weight);
    expect(animalData.sicknessList).to.deep.equal(sicknessList);
    expect(animalData.vaccinationList).to.deep.equal(vaccinationList);
    expect(animalData.foodList).to.deep.equal(foodList);

  });
});
