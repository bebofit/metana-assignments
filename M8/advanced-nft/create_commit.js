import { ethers } from "ethers";

const labelhash = ethers.keccak256(
  ethers.toUtf8Bytes(Math.random().toString())
);

console.log("revealHash", labelhash);

const commitHash = ethers.keccak256(
  ethers.solidityPacked(
    ["address", "bytes32"],
    // add the contract address here
    ["0x9a2E12340354d2532b4247da3704D2A5d73Bd189", labelhash]
  )
);

console.log("commitHash", commitHash);
