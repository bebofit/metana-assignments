const { Network, Alchemy } = require("alchemy-sdk");

const settings = {
  apiKey: process.env.REACT_APP_ALCHEMY_KEY, // Replace with your Alchemy API Key.
  network: Network.ETH_MAINNET, // Replace with your network.
};

const alchemy = new Alchemy(settings);

const USDTAddress = "0xdAC17F958D2ee523a2206206994597C13D831ec7";

export async function GetCoinChartData() {
  const latestBlock = await alchemy.core.getBlockNumber();
  const transactions = await alchemy.core.getAssetTransfers({
    fromBlock: getHexFromNumber(latestBlock - 10),
    category: ["erc20"],
    contractAddresses: [USDTAddress],
  });
  const labels = Array.from(
    { length: 10 },
    (_, i) => i + 1 + latestBlock - 10
  ).map((label) => getHexFromNumber(label));
  const blockGraphData = {
    labels,
    datasets: [
      {
        label: "USDT Volume in last 10 blocks",
        data: labels.map((label) =>
          transactions.transfers
            .filter((transfer) => transfer.blockNum === label)
            .reduce((acc, transfer) => acc + transfer.value, 0)
        ),
        borderColor: "rgb(255, 99, 132)",
        backgroundColor: "rgba(255, 99, 132, 0.5)",
      },
    ],
  };
  return blockGraphData;
}

export async function getBlocksFeePrices() {
  const latestBlock = await alchemy.core.getBlockNumber();
  const labels = Array.from(
    { length: 10 },
    (_, i) => i + 1 + latestBlock - 10
  ).map((label) => getHexFromNumber(label));
  const res = await alchemy.core.send("eth_feeHistory", [
    getHexFromNumber(10),
    getHexFromNumber(latestBlock),
    [],
  ]);
  const basefee = {
    labels,
    datasets: [
      {
        label: "Base Fee Per Gas in last 10 blocks",
        data: res.baseFeePerGas,
        borderColor: "rgb(255, 99, 132)",
        backgroundColor: "rgba(255, 99, 132, 0.5)",
      },
    ],
  };
  const gasUsage = {
    labels,
    datasets: [
      {
        label: "Gas Ratio in last 10 blocks",
        data: res.gasUsedRatio,
        borderColor: "rgb(53, 162, 235)",
        backgroundColor: "rgba(53, 162, 235, 0.5)",
      },
    ],
  };

  return { basefee, gasUsage };
}

function getHexFromNumber(number) {
  return "0x" + number.toString(16);
}
