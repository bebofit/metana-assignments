import { ethers } from "hardhat";

async function main() {
  const partialRefundFactory = await ethers.getContractFactory("PartialRefund");
  const partialRefund = await partialRefundFactory.deploy(100);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  process.exitCode = 1;
});
