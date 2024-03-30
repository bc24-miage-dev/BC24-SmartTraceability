import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";

describe("BC24-Transporter", function () {
    let defaultAdmin: { address: unknown; };
    let minter: { address: unknown; };
    let random: any;
    let breeder: any;
    let transporter: any;
    let slaughterer:any;
    let contract: any;
    let tokenId: any;

    

    beforeEach(async function () {
        const ContractFactory = await ethers.getContractFactory("BC24");
        defaultAdmin = (await ethers.getSigners())[0];
        minter = (await ethers.getSigners())[1];
        random = (await ethers.getSigners())[2];
        breeder = (await ethers.getSigners())[3];
        transporter = (await ethers.getSigners())[4];
        slaughterer = (await ethers.getSigners())[5];

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
        await contract.connect(defaultAdmin).grantRoleToAddress(slaughterer.address, "SLAUGHTER_ROLE");

        const transaction =await contract.connect(breeder).createAnimal(breeder.address);
        tokenId = transaction.value;   
        await contract.connect(breeder).giveAnimalToTransporter(tokenId, transporter.address); 
       
    });

    it("Test contract", async function () {
        expect(await contract.uri(0)).to.equal("");
        expect(await contract.connect(transporter).ownerOf(tokenId)).to.equal(transporter.address);
    })


    it("should allow the transporter to create transporter data after he received an animal", async function () {
        const duration = 1000;
        const temperature = 25;
        const humidity = 50;

        await expect(await contract.connect(transporter).updateTransport(tokenId, duration, temperature, humidity)
        )
            .to.emit(contract, "MetaDataChanged")
            .withArgs("Transport info added successfully.");

        const transportData = await contract.connect(transporter).getTransport(tokenId);
        expect(transportData.duration).to.equal(duration);
        expect(transportData.temperature).to.equal(temperature);
        expect(transportData.humidity).to.equal(humidity);

    });

    it("should not allow transporter to change animal", async function () {
        // Create some sample data
        const placeOfOrigin = "Farm XYZ";
        const dateOfBirth = 1622524800; // June 1, 2021
        const gender = "Male";
        const weight = 1000;
        const sicknessList: [] = []; // Empty list
        const vaccinationList: [] = []; // Empty list
        const foodList: [] = []; // Empty list

        await expect(contract.connect(transporter).updateAnimal(tokenId, placeOfOrigin, dateOfBirth, gender, weight, sicknessList, vaccinationList, foodList)
        ).to.be.revertedWith("Caller is not a breeder")
    });

    it("should transfer animal to slaughterer", async function () { 
        await contract.connect(transporter).transferAnimalToSlaugtherer(tokenId, slaughterer.address);
        expect(await contract.connect(slaughterer).ownerOf(tokenId)).to.equal(slaughterer.address);
      });
});