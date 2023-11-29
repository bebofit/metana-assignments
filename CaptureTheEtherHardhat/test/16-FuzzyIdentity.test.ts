import { expect } from 'chai';
import { Contract, Wallet } from 'ethers';
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

describe('FuzzyIdentityChallenge', () => {
  let target: Contract;
  let attacker: SignerWithAddress;
  let deployer: SignerWithAddress;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    target = await (await ethers.getContractFactory('FuzzyIdentityChallenge', deployer)).deploy();

    await target.deployed();

    target = target.connect(attacker);
  });

  it('exploit', async () => {
    /**
     * YOUR CODE HERE
     * */
    // const wallet = getWallet();
    const wallet = new Wallet(
      '0xd9049714b21da5008b14de9ebe26051f79cab7025b3aba800a6a7fc4f4267973',
      attacker.provider
    );

    let tx;
    tx = await attacker.sendTransaction({
      to: wallet.address,
      value: ethers.utils.parseEther('0.1'),
    });
    await tx.wait();

    const attackFactory = await ethers.getContractFactory('FuzzyIdentityAttack');
    const attackContract = await attackFactory.connect(wallet).deploy(target.address);
    await attackContract.deployed();

    tx = await attackContract.attack();
    await tx.wait();

    expect(await target.isComplete()).to.equal(true);
  });
});
