import { ethers, upgrades } from "hardhat";

async function main() {
  const ContractFactory = await ethers.getContractFactory("BC24");

  const defaultAdmin = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  const minter = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  const upgrader = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  const tokenOwner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  // TODO: Set addresses for the contract arguments below
  const instance = await upgrades.deployProxy(ContractFactory, [
    defaultAdmin,
    minter,
    upgrader,
    tokenOwner,
  ]);
  await instance.waitForDeployment();

  console.log(`Proxy deployed to ${await instance.getAddress()}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
