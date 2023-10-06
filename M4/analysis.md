# Partial Refund Contract 

## 1- 
### found this vulnerability:

Low level call in PartialRefund.sellBack(uint256) (contracts/PartialRefund.sol#26-44):
        - (sent) = address(msg.sender).call{value: eth}() (contracts/PartialRefund.sol#41)
Low level call in PartialRefund.withdraw() (contracts/PartialRefund.sol#51-58):
        - (sent) = _owner.call{value: amount}() (contracts/PartialRefund.sol#56)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#low-level-calls

### solution: 
use payable(address).transfer instead

## 2- 
### found this false positive 
PartialRefund.slitherConstructorVariables() (contracts/PartialRefund.sol#6-65) uses literals with too many digits:
        - total = 1000000 * 10 ** decimals() (contracts/PartialRefund.sol#8)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#too-many-digits

it is just to avoid confusion with having to deal with many zeros.

### solution: 
1e6 instead 

## 3- 
### found this 
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol#4) allows old versions
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol#4) allows old versions
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol#4) allows old versions
Pragma version^0.8.0 (node_modules/@openzeppelin/contracts/utils/Context.sol#4) allows old versions
Pragma version^0.8.0 (contracts/PartialRefund.sol#2) allows old versions
solc-0.8.19 is not recommended for deployment
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity

I think it is a false positive so maybe going to neglect it?

### solution:
None


# Forge Contract

## 1-
### found this vulnerability:
Reentrancy in Forge.mintToken(uint256) in THOR, OBlivion, Dante, Captain America tokens was due to minting then burining

### solution
switch minting to be last thing after burning and emitting events

## 2-
### found this vulnerability:
Forge.mintToken(uint256) (contracts/Forge.sol#50-103) uses timestamp for comparisons
        Dangerous comparisons:
        - block.timestamp - lastMint < coolDownMint (contracts/Forge.sol#51)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#block-timestamp

### solution ?



# Mutation 
used universesimulator mutation 

## Partial Refund 

0 VALID MUTANTS
666 INVALID MUTANTS
0 REDUNDANT MUTANTS
Valid Percentage: 0.0%

## Forge
0 VALID MUTANTS
1363 INVALID MUTANTS
0 REDUNDANT MUTANTS
Valid Percentage: 0.0%

