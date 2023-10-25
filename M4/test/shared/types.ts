import { Signer } from "ethers";
import { PartialRefund, Forge } from "../../typechain-types";

declare module "mocha" {
  export interface Context {
    signers: Signers;
    partialRefund: PartialRefund;
    forgeContract: Forge;
  }
}

export interface Signers {
  deployer: Signer;
  alice: Signer;
  bob: Signer;
}
