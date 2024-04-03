import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";

describe("BC24-Manufacturer", function () {
    let defaultAdmin: { address: unknown; };
    let random: any;
    let transporter: any;
    let slaughterer: any;
    let breeder: any;
    let manufacturer: any;

    let contract: any;
    let animalId: any;
    let carcassId: any;



    beforeEach(async function () {
        const ContractFactory = await ethers.getContractFactory("BC24");
        defaultAdmin = (await ethers.getSigners())[0];
        random = (await ethers.getSigners())[2];
        breeder = (await ethers.getSigners())[3];
        transporter = (await ethers.getSigners())[4];
        slaughterer = (await ethers.getSigners())[5];
        manufacturer = (await ethers.getSigners())[6];

        contract = await upgrades.deployProxy(ContractFactory, [
            defaultAdmin.address
        ]);

        await contract.waitForDeployment();


        await contract.connect(defaultAdmin).grantRoleToAddress(breeder.address, "BREEDER_ROLE");
        await contract.connect(defaultAdmin).grantRoleToAddress(breeder.address, "MINTER_ROLE");

        await contract.connect(defaultAdmin).grantRoleToAddress(transporter.address, "TRANSPORTER_ROLE");
        await contract.connect(defaultAdmin).grantRoleToAddress(slaughterer.address, "SLAUGHTER_ROLE");
        await contract.connect(defaultAdmin).grantRoleToAddress(manufacturer.address, "MANUFACTURERE_ROLE");

        const transaction = await contract.connect(breeder).createAnimal(breeder.address,"Cow");
        animalId = transaction.value;
        await contract.connect(breeder).transferAnimalToTransporter(animalId, transporter.address);
        const slaugtherTransaction = await contract.connect(transporter).transferAnimalToSlaugtherer(animalId, slaughterer.address);
        carcassId = slaugtherTransaction.value
        await contract.connect(slaughterer).transferCarcassToTransporter(carcassId, transporter.address);
        await contract.connect(transporter).transferCarcassToManufacturer(carcassId, manufacturer.address);


    });

    it("Test contract", async function () {
        expect(await contract.uri(0)).to.equal("");
        expect(await contract.connect(manufacturer).ownerOf(carcassId)).to.equal(manufacturer.address);
    })

    it("should create a new MeatNFT which is connected to the carcass", async function () {
        const transaction = await contract.connect(manufacturer).createMeat(carcassId)

        const meatId = transaction.value
        const cascass = await contract.connect(manufacturer).getMeat(meatId)

        expect(await cascass.carcassId).to.equal(carcassId)
    });

    it("update meat data", async function () {
        const transaction = await contract.connect(manufacturer).createMeat(carcassId)

        const meatId = transaction.value

        const agreementNumber = "1111";
        const countryOfCutting = "Schweiz";
        const dateOfCutting = 1622524800;
        const part = "Tongue";
        const isContaminated = false

        await expect(await contract.connect(manufacturer).updateMeat(meatId, agreementNumber, countryOfCutting, dateOfCutting, part, isContaminated)
        )
            .to.emit(contract, "MetaDataChanged")
            .withArgs("Meat info added successfully.");

        const meat = await contract.connect(manufacturer).getMeat(meatId);
        expect(meat.agreementNumber).to.equal(agreementNumber);
        expect(meat.countryOfCutting).to.equal(countryOfCutting);
        expect(meat.dateOfCutting).to.equal(dateOfCutting);


    })

    it("create manufactured product", async function () {
        const transaction = await contract.connect(manufacturer).createMeat(carcassId)

        const meatId = transaction.value

        const agreementNumber = 1;
        const countryOfCutting = "Schweiz";
        const dateOfCutting = 1622524800;
        const part = "Tongue";
        const isContaminated = false

        await expect(await contract.connect(manufacturer).updateMeat(meatId, agreementNumber, countryOfCutting, dateOfCutting, part, isContaminated)
        )
            .to.emit(contract, "MetaDataChanged")
            .withArgs("Meat info added successfully.");


        await expect(await contract.connect(manufacturer).createManufacturedProduct(meatId)
        )
            .to.emit(contract, "NFTMinted")
            .withArgs("ManufacturedProduct created");
    })


    it("update manufacturedproduct data", async function () {
        const transaction = await contract.connect(manufacturer).createMeat(carcassId)

        const meatId = transaction.value

        const productTranscation = await contract.connect(manufacturer).createManufacturedProduct(meatId)
        const manufacturedProductId = productTranscation.value


        const productName = "Schnitzel";
        const dateOfManufacturation = 1622524800;
        const price = 50;
        const description = "Schnitzel aus der Schweiz";

        await expect(await contract.connect(manufacturer).updateManufacturedProduct(manufacturedProductId, dateOfManufacturation, productName, price, description)
        )
            .to.emit(contract, "MetaDataChanged")
            .withArgs("ManufacturedProduct info added successfully.");

        const manufacturedProduct = await contract.connect(manufacturer).getManufacturedProduct(manufacturedProductId);
        expect(manufacturedProduct.productName).to.equal(productName);
        expect(manufacturedProduct.dateOfManufacturation).to.equal(dateOfManufacturation);
    })

    it("create new recipe", async function () { 
        expect(0).to.equal(1)
    });

    it("create new manufacturedProduct with recipe", async function () { 
        expect(0).to.equal(1)
    });

});