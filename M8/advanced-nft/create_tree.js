// off chain code that could be used in node or react to handle the logic
import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";

// Add the whitelabeled addresses and their corresponding token IDs here
const values = [
  ["0x0000000000000000000000000000000000000001", "0"],
  ["0x0000000000000000000000000000000000000002", "1"],
  ["0x0000000000000000000000000000000000000003", "2"],
  ["0x0000000000000000000000000000000000000004", "3"],
  ["0x0000000000000000000000000000000000000005", "4"],
  ["0x0000000000000000000000000000000000000006", "5"],
  ["0x0000000000000000000000000000000000000007", "6"],
  ["0x0000000000000000000000000000000000000008", "7"],
  ["0x6D93fa0b71C38562515b5cAce2D5Eb3c6cA62cAc", "8"],
  ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "9"],
];

// create the tree
const tree = StandardMerkleTree.of(values, ["address", "uint256"]);

console.log("Merkle Root:", tree.root);
fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));
