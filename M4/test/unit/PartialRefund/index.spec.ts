import { ethers } from "hardhat";
import { expect } from "chai";
import { unitPartialFundFixture } from "../../shared/fixtures";

export const runPartialFundTest = (): void => {
  //   // to silent warning for duplicate definition of Transfer event
  //   ethers.utils.Logger.setLogLevel(ethers.utils.Logger.levels.OFF);
  describe(`#buyToken`, function () {
    it(`should buy Token...`, async function () {
      const beforeBalance = await this.partialRefund
        .connect(this.signers.alice)
        .balanceOf(await this.signers.alice.getAddress());
      expect(beforeBalance).to.equal(0);
      const ether = await ethers.provider.getBalance(
        await this.signers.alice.getAddress()
      );
      expect(ether).to.equal(ethers.parseEther("10000.0"));
      await this.partialRefund.connect(this.signers.alice).buyToken({
        value: ethers.parseEther("1.0"),
      });
      const afterBalance = await this.partialRefund
        .connect(this.signers.alice)
        .balanceOf(await this.signers.alice.getAddress());
      expect(afterBalance).to.equal(BigInt("1000000000000000000000"));
      const etherAfter = await ethers.provider.getBalance(
        await this.signers.alice.getAddress()
      );
      expect(etherAfter).to.closeTo(
        ethers.parseEther("9999"),
        ethers.parseEther("0.01")
      );
    });

    it(`should revert if no eth was provided...`, async function () {
      await expect(
        this.partialRefund.connect(this.signers.alice).buyToken()
      ).to.be.revertedWith("user must pay exactly one eth");
    });

    it(`should revert if total supply was finished...`, async function () {
      const fixture = await unitPartialFundFixture(1000000);
      await expect(
        fixture.partialContract.connect(this.signers.alice).buyToken({
          value: ethers.parseEther("1.0"),
        })
      ).to.be.revertedWith("sale passed, better luck next time");
    });
  });

  describe(`#sellBack`, function () {
    it(`should refund...`, async function () {
      // assert before
      const beforeTokenBalance = await this.partialRefund
        .connect(this.signers.alice)
        .balanceOf(await this.signers.alice.getAddress());
      const ether = await ethers.provider.getBalance(
        await this.signers.alice.getAddress()
      );
      expect(ether).to.equal(ethers.parseEther("10000.0"));
      expect(beforeTokenBalance).to.equal(0);
      await this.partialRefund.connect(this.signers.alice).buyToken({
        value: ethers.parseEther("1.0"),
      });
      const afterBalance = await this.partialRefund
        .connect(this.signers.alice)
        .balanceOf(await this.signers.alice.getAddress());
      expect(afterBalance).to.equal(BigInt("1000000000000000000000"));
      // Action
      await this.partialRefund.connect(this.signers.alice).sellBack(1000);
      // assert after
      const finalAliceBalance = await this.partialRefund
        .connect(this.signers.alice)
        .balanceOf(await this.signers.alice.getAddress());
      expect(finalAliceBalance).to.equal(0);
      const etherAfter = await ethers.provider.getBalance(
        await this.signers.alice.getAddress()
      );
      expect(etherAfter).to.closeTo(
        ethers.parseEther("9999.5"),
        ethers.parseEther("0.01")
      );
      const finalContractBalance = await this.partialRefund
        .connect(this.signers.alice)
        .balanceOf(await this.partialRefund.getAddress());
      expect(finalContractBalance).to.equal("1000000000000000000000");
      const etherContractAfter = await ethers.provider.getBalance(
        await this.partialRefund.getAddress()
      );
      expect(etherContractAfter).to.closeTo(
        ethers.parseEther("0.5"),
        ethers.parseEther("0.01")
      );
    });

    it(`should revert if user has no token...`, async function () {
      await expect(
        this.partialRefund.connect(this.signers.alice).sellBack(1000)
      ).to.be.revertedWith("cannot sellback more than what you have");
    });

    it(`should revert if parameter is 0...`, async function () {
      await this.partialRefund.connect(this.signers.alice).buyToken({
        value: ethers.parseEther("1.0"),
      });
      await expect(
        this.partialRefund.connect(this.signers.alice).sellBack(0)
      ).to.be.revertedWith("tokens must be bigger than zero");
    });

    it(`should revert if user tries to sell back more than what he have...`, async function () {
      await this.partialRefund.connect(this.signers.alice).buyToken({
        value: ethers.parseEther("1.0"),
      });
      await expect(
        this.partialRefund.connect(this.signers.alice).sellBack(2000)
      ).to.be.revertedWith("cannot sellback more than what you have");
    });
  });

  describe(`#withdraw`, function () {
    it(`should withdraw if owner...`, async function () {
      await this.partialRefund.connect(this.signers.alice).buyToken({
        value: ethers.parseEther("1.0"),
      });
      await this.partialRefund.withdraw();
      const etherAfter = await ethers.provider.getBalance(
        await this.signers.deployer.getAddress()
      );
      expect(etherAfter).to.closeTo(
        ethers.parseEther("10001.0"),
        ethers.parseEther("0.01")
      );
    });

    it(`should not withdraw if contract has no eth...`, async function () {
      await expect(this.partialRefund.withdraw()).to.be.revertedWith(
        "Nothing to withdraw; contract balance empty"
      );
    });

    it(`should not withdraw if not owner...`, async function () {
      await expect(
        this.partialRefund.connect(this.signers.alice).withdraw()
      ).to.be.revertedWith("only owner");
    });
  });

  describe(`#withdrawTokens`, function () {
    it(`should withdrawTokens if owner...`, async function () {
      await this.partialRefund.connect(this.signers.alice).buyToken({
        value: ethers.parseEther("1.0"),
      });
      await this.partialRefund.connect(this.signers.alice).sellBack(1000);
      await this.partialRefund.withdrawTokens();
      const balance = await this.partialRefund.balanceOf(
        await this.signers.deployer.getAddress()
      );
      // owner + alice
      expect(balance).to.equal("1100000000000000000000");
    });

    it(`should not withdrawTokens if not owner...`, async function () {
      await expect(
        this.partialRefund.connect(this.signers.alice).withdrawTokens()
      ).to.be.revertedWith("only owner");
    });
  });

  describe("receive and fallback", function () {
    it("should invoke the fallback function and do nothing", async function () {
      const tx = this.signers.deployer.sendTransaction({
        to: await this.partialRefund.getAddress(),
        data: "0xAB",
      });
      await expect(tx)
        .to.emit(this.partialRefund, "NoFunc")
        .withArgs("no fallback, Only from buying token");
    });

    it("should invoke the receive function and do nothing", async function () {
      const tx = this.signers.deployer.sendTransaction({
        to: await this.partialRefund.getAddress(),
        data: "0x",
      });
      await expect(tx)
        .to.emit(this.partialRefund, "NoFunc")
        .withArgs("no receive, Only from buying token");
    });
  });
};
