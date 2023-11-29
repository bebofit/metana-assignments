import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers } from 'hardhat';
const { utils } = ethers;

describe('GuessTheSecretNumberChallenge', () => {
  let target: Contract;
  let deployer: SignerWithAddress;
  let attacker: SignerWithAddress;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    target = await (
      await ethers.getContractFactory('GuessTheSecretNumberChallenge', deployer)
    ).deploy({
      value: utils.parseEther('1'),
    });

    await target.deployed();

    target = target.connect(attacker);
  });

  it('exploit', async () => {
    /**
     * YOUR CODE HERE
     * */

    const answerHash = '0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365';
    let secretNumber;
    for (let i = 0; i <= 255; i++) {
      const hash = utils.keccak256([i]);
      if (answerHash === hash) {
        secretNumber = i;
        console.log(`The secret number is ${secretNumber}`);
        break;
      }
    }
    if (secretNumber === undefined) {
      throw new Error('The secret number could not be found');
    }

    const tx = await target.guess(secretNumber, { value: utils.parseEther('1') });
    await tx.wait();

    expect(await target.isComplete()).to.equal(true);
  });
});
