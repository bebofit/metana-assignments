import { ethers } from "hardhat";
import { expect } from "chai";
import { time } from "@nomicfoundation/hardhat-network-helpers";

export const runForgeTest = (): void => {
  describe("uri", function () {
    it("should return uri", async function () {
      const url = await this.forgeContract.connect(this.signers.alice).uri(1);

      expect(url).equal(
        "ipfs://QmVjErHSRQVmZpqUhGYPLWx75wsM8SjSTW7y3bFAMvQPr2/1"
      );
    });

    it("should revert if token doesnt exist", async function () {
      await expect(
        this.forgeContract.connect(this.signers.alice).uri(10)
      ).to.be.revertedWithCustomError(this.forgeContract, `InvalidTokenId`);
    });
  });

  describe("burn", function () {
    // should burn any token if have token more than 0
    it("should burn any token if have token more than 0", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
      await this.forgeContract.mintToken(1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(1);

      await this.forgeContract.burn(1, 1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
    });

    it("should burn gold to silver", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);
      await this.forgeContract.mintToken(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(1);

      await this.forgeContract.burn(0, 1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(1);
    });

    it("should burn gold to bronze", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);
      await this.forgeContract.mintToken(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(1);

      await this.forgeContract.burn(0, 2);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(1);
    });

    it("should burn silver to gold", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
      await this.forgeContract.mintToken(1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(1);

      await this.forgeContract.burn(1, 0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(1);
    });

    it("should burn silver to bronze", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
      await this.forgeContract.mintToken(1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(1);

      await this.forgeContract.burn(1, 2);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(1);
    });

    it("should burn bronze to gold", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      await this.forgeContract.mintToken(2);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(1);

      await this.forgeContract.burn(2, 0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(1);
    });

    it("should burn bronze to silver", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      await this.forgeContract.mintToken(2);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(1);

      await this.forgeContract.burn(2, 1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(1);
    });

    it("should burn and not mint the same token", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      await this.forgeContract.mintToken(2);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(1);

      await this.forgeContract.burn(2, 2);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
    });

    it("should burn thor and mint no silver", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      await this.forgeContract.mintToken(0);
      await time.increase(70);
      await this.forgeContract.mintToken(1);
      await time.increase(70);
      await this.forgeContract.mintToken(3);
      await this.forgeContract.burn(3, 1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 3)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
    });

    it("should burn OBLIVION_SWORD and mint no silver", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      await this.forgeContract.mintToken(1);
      await time.increase(70);
      await this.forgeContract.mintToken(2);
      await time.increase(70);
      await this.forgeContract.mintToken(4);
      await this.forgeContract.burn(4, 1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 4)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
    });

    it("should burn CAPTAIN_SHIELD and mint no silver", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      await this.forgeContract.mintToken(0);
      await time.increase(70);
      await this.forgeContract.mintToken(2);
      await time.increase(70);
      await this.forgeContract.mintToken(5);
      await this.forgeContract.burn(5, 1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 5)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
    });

    it("should burn DANTE_KEY and mint no silver", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      await this.forgeContract.mintToken(0);
      await time.increase(70);
      await this.forgeContract.mintToken(1);
      await time.increase(70);
      await this.forgeContract.mintToken(2);
      await time.increase(70);
      await this.forgeContract.mintToken(6);
      await this.forgeContract.burn(6, 1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 6)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
    });

    it("should not burn if user has no tokens", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);

      await expect(this.forgeContract.burn(1, 0)).to.be.revertedWithCustomError(
        this.forgeContract,
        `NothingToBurn`
      );
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
    });

    it("should not burn if not a valid token id", async function () {
      await expect(
        this.forgeContract.burn(10, 0)
      ).to.be.revertedWithCustomError(this.forgeContract, `InvalidTokenId`);
    });
    it("should not burn if not a valid new token id", async function () {
      await expect(this.forgeContract.burn(0, 3)).to.be.revertedWithCustomError(
        this.forgeContract,
        `InvalidTokenId`
      );
    });
  });

  describe("mintToken", function () {
    it("should mint gold token", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);

      await this.forgeContract.mintToken(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(1);
    });

    it("should mint silver token", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);

      await this.forgeContract.mintToken(1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(1);
    });

    it("should mint bronze token", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);

      await this.forgeContract.mintToken(2);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(1);
    });

    it("should mint thor token", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 3)
      ).to.be.equal(0);

      await this.forgeContract.mintToken(0);
      await time.increase(70);
      await this.forgeContract.mintToken(1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(1);
      await time.increase(70);
      await expect(this.forgeContract.mintToken(3))
        .to.emit(this.forgeContract, "Forged")
        .withArgs(3);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);

      expect(
        await this.forgeContract.balanceOf(deployerAddress, 3)
      ).to.be.equal(1);
    });

    it("should mint oblivion sword token", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 4)
      ).to.be.equal(0);

      await this.forgeContract.mintToken(2);
      await time.increase(70);
      await this.forgeContract.mintToken(1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(1);
      await time.increase(70);
      await expect(this.forgeContract.mintToken(4))
        .to.emit(this.forgeContract, "Forged")
        .withArgs(4);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);

      expect(
        await this.forgeContract.balanceOf(deployerAddress, 4)
      ).to.be.equal(1);
    });

    it("should mint Captain america shield token", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 5)
      ).to.be.equal(0);

      await this.forgeContract.mintToken(0);
      await time.increase(70);
      await this.forgeContract.mintToken(2);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(1);
      await time.increase(70);
      await expect(this.forgeContract.mintToken(5))
        .to.emit(this.forgeContract, "Forged")
        .withArgs(5);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);

      expect(
        await this.forgeContract.balanceOf(deployerAddress, 5)
      ).to.be.equal(1);
    });

    it("should mint Dante key token", async function () {
      const deployerAddress = await this.signers.deployer.getAddress();
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 6)
      ).to.be.equal(0);

      await this.forgeContract.mintToken(2);
      await time.increase(70);
      await this.forgeContract.mintToken(1);
      await time.increase(70);
      await this.forgeContract.mintToken(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(1);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(1);
      await time.increase(70);
      await expect(this.forgeContract.mintToken(6))
        .to.emit(this.forgeContract, "Forged")
        .withArgs(6);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 2)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 1)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 0)
      ).to.be.equal(0);
      expect(
        await this.forgeContract.balanceOf(deployerAddress, 6)
      ).to.be.equal(1);
    });

    it("shouldnot mint thor if no silver or gold available", async function () {
      await expect(this.forgeContract.mintToken(3))
        .to.revertedWithCustomError(this.forgeContract, "InSufficientTokens")
        .withArgs("must at least have one gold and one sliver");
    });

    it("shouldnot mint thor if no silver or gold available", async function () {
      await this.forgeContract.mintToken(0);
      await time.increase(60);
      await expect(this.forgeContract.mintToken(3))
        .to.revertedWithCustomError(this.forgeContract, "InSufficientTokens")
        .withArgs("must at least have one gold and one sliver");
    });

    it("shouldnot mint oblivion sword if no bronze or silver available", async function () {
      await expect(this.forgeContract.mintToken(4))
        .to.revertedWithCustomError(this.forgeContract, "InSufficientTokens")
        .withArgs("must at least have one bronze and one sliver");
    });

    it("shouldnot mint oblivion sword if no bronze or silver available", async function () {
      await this.forgeContract.mintToken(2);
      await time.increase(60);
      await expect(this.forgeContract.mintToken(4))
        .to.revertedWithCustomError(this.forgeContract, "InSufficientTokens")
        .withArgs("must at least have one bronze and one sliver");
    });

    it("shouldnot mint captain america if no bronze or gold available", async function () {
      await expect(this.forgeContract.mintToken(5))
        .to.revertedWithCustomError(this.forgeContract, "InSufficientTokens")
        .withArgs("must at least have one bronze and one gold");
    });

    it("shouldnot mint captain america if no bronze or gold available", async function () {
      await this.forgeContract.mintToken(2);
      await time.increase(60);
      await expect(this.forgeContract.mintToken(5))
        .to.revertedWithCustomError(this.forgeContract, "InSufficientTokens")
        .withArgs("must at least have one bronze and one gold");
    });

    it("shouldnot mint dante if no silver or gold or bronze available", async function () {
      await expect(this.forgeContract.mintToken(6))
        .to.revertedWithCustomError(this.forgeContract, "InSufficientTokens")
        .withArgs("must at least have one bronze and one gold and one sliver");
    });

    it("shouldnot mint dante if no silver or gold or bronze available", async function () {
      await this.forgeContract.mintToken(2);
      await time.increase(60);
      await expect(this.forgeContract.mintToken(6))
        .to.revertedWithCustomError(this.forgeContract, "InSufficientTokens")
        .withArgs("must at least have one bronze and one gold and one sliver");
    });

    it("shouldnot mint dante if no silver or gold or bronze available", async function () {
      await this.forgeContract.mintToken(2);
      await time.increase(60);
      await this.forgeContract.mintToken(0);
      await time.increase(60);
      await expect(this.forgeContract.mintToken(6))
        .to.revertedWithCustomError(this.forgeContract, "InSufficientTokens")
        .withArgs("must at least have one bronze and one gold and one sliver");
    });

    it("should not mint token if still in cooldown", async function () {
      await this.forgeContract.mintToken(1);
      await expect(
        this.forgeContract.connect(this.signers.alice).mintToken(1)
      ).to.be.revertedWithCustomError(this.forgeContract, `MintInCoolDown`);
    });

    it("should revert if token id is invalid", async function () {
      await expect(
        this.forgeContract.connect(this.signers.alice).mintToken(10)
      ).to.be.revertedWithCustomError(this.forgeContract, `InvalidTokenId`);
    });
  });
};
