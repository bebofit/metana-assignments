// scripts/upgrade_box.js
const { ethers, upgrades } = require("hardhat");

// proxy address
const PROXY = "0x150790A693873A342CaFCfDD3C567b1c7A074F12";

async function main() {
  const SimpleNFTV2 = await ethers.getContractFactory("SimpleNFTGodMode");
  console.log("Upgrading SimpleNFTGodMode...");
  await upgrades.upgradeProxy(PROXY, SimpleNFTV2, { timeout: 300000 });
  console.log("SimpleNFTGodMode upgraded");
}

main();
