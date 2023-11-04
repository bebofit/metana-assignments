import { Bar } from "react-chartjs-2";
import { ChartData } from "chart.js";
import { useEffect, useState } from "react";
import { GetCoinChartData } from "./alchemy";
interface CoinChartProps {
  blockNumber: number;
}

const options = {
  responsive: true,
  plugins: {
    legend: {
      position: "top" as const,
    },
    title: {
      display: false,
    },
  },
};

export default function CoinChart({ blockNumber }: CoinChartProps) {
  const [coinData, setCoinData] =
    useState<ChartData<"bar", number[], string>>();

  useEffect(() => {
    async function data() {
      const coinD = await GetCoinChartData();
      setCoinData(coinD);
    }
    data();
  }, [blockNumber]);

  return (
    <div
      style={{
        width: "100%",
        height: "500px",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        flexDirection: "column",
        marginTop: "150px",
      }}
    >
      <h1>USDT Coin Volume</h1>
      {coinData && <Bar options={options} data={coinData} />}
    </div>
  );
}
