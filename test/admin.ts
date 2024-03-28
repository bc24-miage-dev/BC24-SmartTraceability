import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";
describe("BC24-Admin", function () {
    let defaultAdmin: { address: unknown; };
    let minter: { address: unknown; };
    let random: any;
    let contract: any;

    beforeEach(async function () {
        const ContractFactory = await ethers.getContractFactory("BC24");
        defaultAdmin = (await ethers.getSigners())[0];
        minter = (await ethers.getSigners())[1];
        random = (await ethers.getSigners())[2];

        contract = await upgrades.deployProxy(ContractFactory, [
            defaultAdmin.address
        ]);

        await contract.waitForDeployment();

        // grant the roles
        await contract.connect(defaultAdmin).grantRoleToAddress(minter.address, "MINTER_ROLE");

    });

    it("Test contract", async function () {
        expect(await contract.uri(0)).to.equal("");
    })

    it("should only let default admin assign roles", async function () {
        await expect(contract.connect(minter).grantRoleToAddress(minter.address, "MINTER_ROLE")).to.be.revertedWithCustomError(contract, "AccessControlUnauthorizedAccount");

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
})