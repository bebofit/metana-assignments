import React, { useEffect } from "react";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";
import { GetCoinChartData, getBlocksFeePrices } from "./alchemy/index";
import MainChart from "./MainChart";
import { ChartData } from "chart.js";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

export default function App() {
  const [coinData, setCoinData] =
    React.useState<ChartData<"line", number[], string>>();
  const [gasData, setGasData] = React.useState<{
    basefee: ChartData<"line", number[], string>;
    gasUsage: ChartData<"line", number[], string>;
  }>();

  useEffect(() => {
    async function data() {
      const coinD = await GetCoinChartData();
      setCoinData(coinD);
      const gasD = await getBlocksFeePrices();
      setGasData(gasD);
    }

    const intervalId = setInterval(async () => {
      //assign interval to a variable to clear it.
      const coinD = await GetCoinChartData();
      setCoinData(coinD);
      const gasD = await getBlocksFeePrices();
      setGasData(gasD);
    }, 15000);

    data();
    return () => clearInterval(intervalId);
  }, []);

  return (
    <>
      {coinData && <MainChart data={coinData} title="USDT Coin Volume" />}
      {gasData && <MainChart data={gasData.basefee} title="Base Fee" />}
      {gasData && <MainChart data={gasData.gasUsage} title="Gas Usage Ratio" />}
    </>
  );
}
