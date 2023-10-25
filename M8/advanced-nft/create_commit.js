import { ethers } from "ethers";

const labelhash = ethers.keccak256(
  ethers.toUtf8Bytes(Math.random().toString())
);

console.log(labelhash);
