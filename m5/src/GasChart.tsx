import { Line } from "react-chartjs-2";
import { ChartOptions } from "chart.js";
import { useEffect, useState } from "react";
import { getBlocksFeePrices } from "./alchemy";

const options: ChartOptions<"line"> = {
  responsive: true,
  interaction: {
    mode: "index",
    intersect: false,
  },
  plugins: {
    title: {
      display: true,
      text: "Chart.js Line Chart - Multi Axis",
    },
  },
  scales: {
    y: {
      type: "linear",
      display: true,
      position: "left",
    },
    y1: {
      type: "linear",
      display: true,
      position: "right",

      // grid line settings
      grid: {
        drawOnChartArea: false, // only want the grid lines for one axis to show up
      },
    },
  },
};

export default function GasChart({ blockNumber }: { blockNumber: number }) {
  const [gasData, setGasData] = useState<any>();

  useEffect(() => {
    async function data() {
      const gasD = await getBlocksFeePrices();
      setGasData(gasD);
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
      <h1>Gas Usage Ratio</h1>
      {gasData && <Line options={options} data={gasData} />}
    </div>
  );
}
