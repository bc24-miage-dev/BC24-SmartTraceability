import { ethers, upgrades } from "hardhat";

async function main() {
  const defaultAdmin = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  // const minter = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  // const upgrader = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  // const tokenOwner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

  // Déploiement du contrat AnimalData
  const AnimalContract = await ethers.getContractFactory("AnimalData");
  const animalContract = await upgrades.deployProxy(AnimalContract, [
    defaultAdmin,
  ]);
  await animalContract.waitForDeployment();
  const animalDataAddress = await animalContract.getAddress();
  console.log(`Animal Contract deployed to ${animalDataAddress}`);

  // Déploiement du contrat CarcassData
  const CarcassContract = await ethers.getContractFactory("CarcassData");
  const carcassContract = await upgrades.deployProxy(CarcassContract, [
    defaultAdmin,
  ]);
  await carcassContract.waitForDeployment();
  const carcassDataAddress = await carcassContract.getAddress();
  console.log(`Carcass Contract deployed to ${carcassDataAddress}`);

  // Déploiement du contrat TransportData
  const TransportData = await ethers.getContractFactory("TransportData");
  const transportContract = await upgrades.deployProxy(TransportData, [
    defaultAdmin,
  ]);
  await transportContract.waitForDeployment();
  const transportDataAddress = await transportContract.getAddress();
  console.log(`Transport Contract deployed to ${transportDataAddress}`);

  // Déploiement du contrat MeatData
  const MeatData = await ethers.getContractFactory("MeatData");
  const meatContract = await upgrades.deployProxy(MeatData, [
    defaultAdmin,
  ]);
  await meatContract.waitForDeployment();
  const meatDataAddress = await meatContract.getAddress();
  console.log(`Meat Contract deployed to ${meatDataAddress}`);

  // Déploiement du contrat RecipeData
  const RecipeContract = await ethers.getContractFactory("RecipeData");
  const recipeContract = await upgrades.deployProxy(RecipeContract, [
    defaultAdmin,
  ]);
  await recipeContract.waitForDeployment();
  const recipeDataAddress = await recipeContract.getAddress();
  console.log(`Recipe Contract deployed to ${recipeDataAddress}`);

  // Déploiement du contrat BC24 en utilisant les adresses des contrats déployés comme dépendances
  const ContractFactory = await ethers.getContractFactory("BC24");
  const contract = await upgrades.deployProxy(ContractFactory, [
    defaultAdmin,
    animalDataAddress,
    carcassDataAddress,
    recipeDataAddress,
    meatDataAddress,
    transportDataAddress,
  ]);
  await contract.waitForDeployment();
  const bc24Address = await contract.getAddress();
  console.log(`BC24 Contract deployed to ${bc24Address}`);
}

// Gestion des erreurs
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
