import { ethers, upgrades } from "hardhat";

async function main() {
  const ContractFactory = await ethers.getContractFactory("BC24");

  const AnimalContract = await ethers.getContractFactory("AnimalData");

  const defaultAdmin = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  const minter = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  const upgrader = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  const tokenOwner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

  const animalContract = await upgrades.deployProxy(AnimalContract, [
    defaultAdmin,
  ]);

  await animalContract.waitForDeployment();

  const animalDataAddress = await animalContract.getAddress();
  console.log(`Animal Contract deployed to ${animalDataAddress}`);

  const contract = await upgrades.deployProxy(ContractFactory, [
    defaultAdmin,
    animalDataAddress,
  ]);
  await contract.waitForDeployment();
  const bc24Address = await contract.getAddress();
  console.log(`BC24 Contract deployed to ${bc24Address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
