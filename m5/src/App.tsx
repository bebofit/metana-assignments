import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  BarElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";
import { listenToWS } from "./alchemy/index";
import CoinChart from "./CoinChart";
import GasChart from "./GasChart";
import { useEffect, useState } from "react";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  BarElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

export default function App() {
  const [blockNumber, setBlockNumber] = useState<number>(0);

  useEffect(() => {
    listenToWS((bNumber: number) => {
      setBlockNumber(bNumber);
    });
  }, []);

  return (
    <>
      <CoinChart blockNumber={blockNumber} />
      <GasChart blockNumber={blockNumber} />
    </>
  );
}
