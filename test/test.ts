import { expect } from "chai";
import { ethers, upgrades } from "hardhat";

describe("BC24", function () {
  let defaultAdmin;
  let minter;
  let upgrader;
  let owner;

  let contract;

  beforeEach(async function () {
    const ContractFactory = await ethers.getContractFactory("BC24");
    defaultAdmin = (await ethers.getSigners())[0];
    minter = (await ethers.getSigners())[1];
    upgrader = (await ethers.getSigners())[2];
    owner = (await ethers.getSigners())[3];

    contract = await upgrades.deployProxy(ContractFactory, [
      defaultAdmin.address,
      minter.address,
      defaultAdmin.address,
      defaultAdmin.address,
    ]);

    await contract.waitForDeployment();
  });

  it("Test contract", async function () {
    expect(await contract.uri(0)).to.equal("");
  });

  it("should allow only the minter role to create tokens", async function () {
    await expect(contract.connect(minter).createToken(minter.address))
      .to.emit(contract, "NFTMinted")
      .withArgs(0);

    const indexAfterMint = await contract.getTokenIndex();
    expect(indexAfterMint).to.equal(1);
  });

  it("should throw when others than minters try to create tokens", async function () {
    await expect(
      contract.connect(defaultAdmin).createToken(defaultAdmin.address)
    ).Throw;
  });

  it("should mint tokens and increment _nextTokenId", async function () {
    await expect(contract.connect(minter).createToken(minter.address))
      .to.emit(contract, "NFTMinted")
      .withArgs(0);

    await expect(contract.connect(minter).createToken(minter.address))
      .to.emit(contract, "NFTMinted")
      .withArgs(1);

    const indexAfterMint = await contract.getTokenIndex();
    expect(indexAfterMint).to.equal(2);
  });

  /* Tests needed: 
  For basic functionality: 
    - addBreedingInfo
    - addRenderingPlantInfo
    - getMetaData
    - destroyToken
  
  Additonal tests:
    - transfer

  Future: 
    - role based tests
    - upgrade
  */
});
