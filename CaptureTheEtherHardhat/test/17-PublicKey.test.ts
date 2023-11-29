import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers } from 'hardhat';

describe('PublicKey', () => {
  let target: Contract;
  let deployer: SignerWithAddress;
  let attacker: SignerWithAddress;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    target = await (await ethers.getContractFactory('PublicKeyChallenge', deployer)).deploy();

    await target.deployed();

    target = target.connect(attacker);
  });

  it('exploit', async () => {
    /**
     * YOUR CODE HERE
     * */
    await target.authenticate(
      '0x613a8d23bd34f7e568ef4eb1f68058e77620e40079e88f705dfb258d7a06a1a0364dbe56cab53faf26137bec044efd0b07eec8703ba4a31c588d9d94c35c8db4'
    );
    expect(await target.isComplete()).to.equal(true);
  });
});
