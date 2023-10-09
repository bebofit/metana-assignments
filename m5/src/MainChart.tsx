import { Line } from "react-chartjs-2";
import { ChartData } from "chart.js";
import { useEffect } from "react";
interface MainChartProps {
  title: string;
  data: ChartData<"line", number[], string>;
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

export default function MainChart({ title, data }: MainChartProps) {
  useEffect(() => {}, []);

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
      <h1>{title}</h1>
      <Line options={options} data={data} />
    </div>
  );
}
