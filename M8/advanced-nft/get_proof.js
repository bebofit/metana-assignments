import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";

// (1)
const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json")));

// (2)
for (const [i, v] of tree.entries()) {
  // insert the address of the whitelisted account
  if (v[0] === "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4") {
    // (3)
    const proof = tree.getProof(i);
    console.log("Value:", v);
    console.log("Proof:", proof);
  }
}

// ["0xa7f95bf9b860c01d4d702abd2b530a36520fe6fef8b5598d7c9580b61fbd5b75","0x63340ab877f112a2b7ccdbf0eb0f6d9f757ab36ecf6f6e660df145bcdfb67a19","0xd3699ec2eb93811729ed8d873c5b89f4fa5914e0003a44b4098e7c130bb1dc43"]
