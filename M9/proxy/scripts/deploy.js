// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers, upgrades } = require("hardhat");

async function main() {
  const StakeToken = await ethers.getContractFactory("StakeToken");
  console.log("Deploying Stake Token...");
  const stakedTokenContract = await upgrades.deployProxy(StakeToken, [42], {
    initializer: "initialize",
  });
  await stakedTokenContract.waitForDeployment();
  const stakedTokenAddress = await stakedTokenContract.getAddress();
  console.log("Staked Token deployed to:", stakedTokenAddress);

  const SimpleNft = await ethers.getContractFactory("SimpleNFT");
  console.log("Deploying Simple NFT...");
  const simpleNftContract = await upgrades.deployProxy(SimpleNft, [], {
    initializer: "initialize",
  });
  await simpleNftContract.waitForDeployment();
  const simpleNftAddress = await simpleNftContract.getAddress();
  console.log("Simple NFT deployed to:", simpleNftAddress);

  const Stake = await ethers.getContractFactory("StakeNFT");
  console.log("Deploying Stack...");
  const stakedContract = await upgrades.deployProxy(
    Stake,
    [simpleNftAddress, stakedTokenAddress],
    {
      initializer: "initialize",
    }
  );
  await stakedContract.waitForDeployment();
  const stakedAddress = await stakedContract.getAddress();
  console.log("Stake  deployed to:", stakedAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
