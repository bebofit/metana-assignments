import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import {
  getSigners,
  unitForgeFixture,
  unitPartialFundFixture,
} from "../shared/fixtures";
import { Signers } from "../shared/types";
import { runPartialFundTest } from "./PartialRefund/index.spec";
import { runForgeTest } from "./Forge/index.spec";

describe(`Unit tests`, async () => {
  before(async function () {
    const { deployer, alice, bob } = await loadFixture(getSigners);

    this.signers = {} as Signers;
    this.signers.deployer = deployer;
    this.signers.alice = alice;
    this.signers.bob = bob;
  });

  describe(`Partial Funds`, async () => {
    beforeEach(async function () {
      const { partialContract } = await loadFixture(unitPartialFundFixture);
      this.partialRefund = partialContract;
    });

    runPartialFundTest();
  });

  describe(`Forge`, async () => {
    beforeEach(async function () {
      const { forgeContract } = await loadFixture(unitForgeFixture);
      this.forgeContract = forgeContract;
    });

    runForgeTest();
  });
});
