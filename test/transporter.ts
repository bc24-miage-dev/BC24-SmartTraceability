import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";

describe("BC24-Transporter", function () {
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


    it("should allow the transporter to create transporter data after he received an animal", async function () {
        await contract.connect(breeder).createAnimal(breeder.address);
        await contract.connect(breeder).giveAnimalToTransporter(0, transporter.address);

        expect(await contract.connect(transporter).ownerOf(0)).to.equal(transporter.address);

        // Create some sample data
        const duration = 1000;
        const temperature = 25;
        const humidity = 50;

        await expect(await contract.connect(transporter).updateTransport(0, duration, temperature, humidity)
        )
            .to.emit(contract, "MetaDataChanged")
            .withArgs("Transport info added successfully.");

        const transportData = await contract.connect(transporter).getTransport(0);
        expect(transportData.duration).to.equal(duration);
        expect(transportData.temperature).to.equal(temperature);
        expect(transportData.humidity).to.equal(humidity);

    });

    it("should not allow transporter to change animal", async function () {
        await contract.connect(breeder).createAnimal(breeder.address);
        await contract.connect(breeder).giveAnimalToTransporter(0, transporter.address);

        expect(await contract.connect(transporter).ownerOf(0)).to.equal(transporter.address);

        // Create some sample data
        const placeOfOrigin = "Farm XYZ";
        const dateOfBirth = 1622524800; // June 1, 2021
        const gender = "Male";
        const weight = 1000;
        const sicknessList: [] = []; // Empty list
        const vaccinationList: [] = []; // Empty list
        const foodList: [] = []; // Empty list

        await expect(contract.connect(transporter).updateAnimal(0, placeOfOrigin, dateOfBirth, gender, weight, sicknessList, vaccinationList, foodList)
        ).to.be.revertedWith("Caller is not a breeder")
    });
});