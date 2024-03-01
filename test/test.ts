import { expect } from "chai";
import { ethers, upgrades } from "hardhat";

describe("BC24", function () {
  it("Test contract", async function () {
    const ContractFactory = await ethers.getContractFactory("BC24");

    const defaultAdmin = (await ethers.getSigners())[0].address;
    const minter = (await ethers.getSigners())[1].address;
    const upgrader = (await ethers.getSigners())[2].address;

    const instance = await upgrades.deployProxy(ContractFactory, [defaultAdmin, minter, upgrader]);
    await instance.waitForDeployment();

    expect(await instance.uri(0)).to.equal("");
  });
});
