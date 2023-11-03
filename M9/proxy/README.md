# cmd

env $(cat .env) npx hardhat run --network goerli scripts/deploy.js

env $(cat .env) npx hardhat verify --network goerli [ADDRESS]


# Deployed Addresses on Goerli
for address transactions: [https://goerli.etherscan.io/address/0x6D93fa0b71C38562515b5cAce2D5Eb3c6cA62cAc]

Proxy Admin: 0x7c87b641ad0eab36ad8e60521e1529524474051d

Simple NFT Proxy: 0x150790A693873A342CaFCfDD3C567b1c7A074F12 (proxy is now looking at V2)
Simple NFT V1: 0xba9d476c5f29f4140bc8351c8baa942aa6220fbf

Token Proxy: 0x63d2e0b1ac24ce256530a89881ad7f83cd4a5a5c
Token: 0x1ae843953cdb84feddea2254b87971f5e1c48abf

Stake Proxy: 0xb9f69d7687681af3da8486bc9fda1820dfdd4622
Stake Proxy: 0xcb8152de360282ba0da28abc4e3f98e537140c6b

Simple NFT V2:  0x44238e9a32c542fd075c03e3a916d8ac94c215d4

