import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";

describe("BC24-Carcass", function () {
    let defaultAdmin: { address: unknown; };
    let random: any;
    let transporter: any;
    let slaughterer:any;
    let breeder:any;
    let contract: any;
    let animalId: any;

    

    beforeEach(async function () {
        const ContractFactory = await ethers.getContractFactory("BC24");
        defaultAdmin = (await ethers.getSigners())[0];
        random = (await ethers.getSigners())[2];
        breeder = (await ethers.getSigners())[3];
        transporter = (await ethers.getSigners())[4];
        slaughterer = (await ethers.getSigners())[5];

        contract = await upgrades.deployProxy(ContractFactory, [
            defaultAdmin.address
        ]);

        await contract.waitForDeployment();


        await contract.connect(defaultAdmin).grantRoleToAddress(breeder.address, "BREEDER_ROLE");
        await contract.connect(defaultAdmin).grantRoleToAddress(breeder.address, "MINTER_ROLE");

        await contract.connect(defaultAdmin).grantRoleToAddress(transporter.address, "TRANSPORTER_ROLE");
        await contract.connect(defaultAdmin).grantRoleToAddress(slaughterer.address, "SLAUGHTER_ROLE");

        const transaction =await contract.connect(breeder).createAnimal(breeder.address);
        animalId = transaction.value;   
        await contract.connect(breeder).giveAnimalToTransporter(animalId, transporter.address); 
        await contract.connect(transporter).transferAnimalToSlaugtherer(animalId, slaughterer.address); 
       
    });

    it("Test contract", async function () {
        expect(await contract.uri(0)).to.equal("");
        expect(await contract.connect(slaughterer).ownerOf(animalId)).to.equal(slaughterer.address);
    })

    it("should make sure the animal is still alive", async function () {
        const animal = await contract.connect(slaughterer).getAnimal(animalId)
        expect(await animal.isDead).to.equal(false)
    });

    it("should create a new carcassNFT which is connected to the now dead animal", async function () {
        const transaction = await contract.connect(slaughterer).slaughterAnimal(animalId)

        const animal = await contract.connect(slaughterer).getAnimal(animalId)
        expect(await animal.isDead).to.equal(true)

        const carcassId = transaction.value
        const cascas = await contract.connect(slaughterer).getCarcass(carcassId)

        expect(await cascas.animalId).to.equal(animalId)
    });

    it("should not create carcas of already slaughtered animal", async function () {
        await contract.connect(slaughterer).slaughterAnimal(animalId);
        await expect(contract.connect(slaughterer).slaughterAnimal(animalId))
        .to.be.revertedWith("Animal already has been slaughtered")
    });

    
});