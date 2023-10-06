import { ContractFactory, Wallet } from "ethers";
import { ethers } from "hardhat";
import { Signers } from "./types";
import { PartialRefund, Forge } from "../../typechain-types";

type UnitPartialFundFixtureType = {
  partialContract: PartialRefund;
};

type UnitForgeFixtureType = {
  forgeContract: Forge;
};

export async function getSigners(): Promise<Signers> {
  const [deployer, alice, bob] = await ethers.getSigners();

  return { deployer, alice, bob };
}

export async function unitPartialFundFixture(
  amount?: number
): Promise<UnitPartialFundFixtureType> {
  const { deployer } = await getSigners();

  const partialRefundFactory: ContractFactory = await ethers.getContractFactory(
    `PartialRefund`
  );

  const partialContract = (await partialRefundFactory
    .connect(deployer)
    .deploy(amount ?? 100)) as PartialRefund;

  return { partialContract };
}

export async function unitForgeFixture(): Promise<UnitForgeFixtureType> {
  const { deployer } = await getSigners();

  const forgeFactory: ContractFactory = await ethers.getContractFactory(
    `Forge`
  );

  const forgeContract = (await forgeFactory
    .connect(deployer)
    .deploy()) as Forge;

  return { forgeContract };
}
