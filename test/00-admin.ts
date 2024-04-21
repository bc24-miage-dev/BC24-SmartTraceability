import { expect, assert } from "chai";
import { ethers, upgrades } from "hardhat";
import { SetupService } from "./setupService";
describe("BC24-Admin", function () {
  let defaultAdmin: any;
  let minter: any;
  let transporter: any;
  let slaughterer: any;
  let breeder: any;
  let contract: any;
  let random: any;

  let setupService: any;

  beforeEach(async function () {
    /* This it the general setup needed for all the contracts*/
    /* If a new contract is put into an interface it needs to be added likewise in the SetupService */
    setupService = new SetupService();
    await setupService.setup();

    defaultAdmin = setupService.defaultAdmin;
    minter = setupService.minter;
    breeder = setupService.breeder;
    transporter = setupService.transporter;
    slaughterer = setupService.slaughterer;
    random = setupService.random;
    contract = setupService.contract;
  });

  it("Test contract", async function () {
    expect(await contract.uri(0)).to.equal("");
  });

  it("should only let default admin assign roles", async function () {
    await expect(
      contract.connect(minter).grantRoleToAddress(minter.address, "MINTER_ROLE")
    ).to.be.revertedWithCustomError(
      contract,
      "AccessControlUnauthorizedAccount"
    );
  });

  it("should assign MINTER_ROLE role to an address", async function () {
    const tx = await contract
      .connect(defaultAdmin)
      .grantRoleToAddress(random.address, "MINTER_ROLE");
    const receipt = await tx.wait();
    const RoleGrantedEvent = contract.filters.RoleGranted(null, null, null);
    const events = await contract.queryFilter(
      RoleGrantedEvent,
      receipt.blockNumber,
      receipt.blockNumber
    );
    assert.equal(events.length, 1, "Should have emitted one RoleGranted event");
    const eventArgs = events[0].args;
    assert.equal(
      eventArgs.account,
      random.address,
      "Should have correct minter address"
    );
  });
});
