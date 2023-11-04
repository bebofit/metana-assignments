import "./App.css";
import { ethers } from "ethers";
import abi from "./abi.json";
import { useEffect, useState, useCallback } from "react";
import ForgeNav from "./ForgeNav";
import NoWallet from "./NoWallet";
import Forge from "./Forge";

const contractAddress = "0xAC1f1cb5d10B800EEfd1DdfBd1af93A9D3202907";

function App() {
  const [user, setUser] = useState(null);
  const [isValidNetwork, setNetwork] = useState(true);
  const [contract, setContract] = useState(null);

  const loadData = useCallback(async () => {
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      const signer = provider.getSigner();
      const address = await signer.getAddress();
      setUser(address);
      const networkId = await provider.getNetwork();
      console.log(networkId);
      if (networkId.chainId !== 80001) {
        console.log("wrong network");
        await window.ethereum.request({
          method: "wallet_addEthereumChain",
          params: [
            {
              chainId: "0x13881",
              rpcUrls: ["https://rpc-mumbai.maticvigil.com"],
              chainName: "Mumbai",
              nativeCurrency: {
                name: "MATIC",
                symbol: "MATIC",
                decimals: 18,
              },
              blockExplorerUrls: ["https://mumbai.polygonscan.com"],
            },
          ],
        });
        setNetwork(true);
      }
      const contract = new ethers.Contract(contractAddress, abi, signer);
      setContract(contract);
    } catch (error) {
      console.log(error);
      alert("FAILED TO CONNECT TO METAMASK");
    }
  }, []);

  useEffect(() => {
    if (window.ethereum) {
      window.ethereum.on("chainChanged", (networkId) => {
        console.log(networkId);
        if (networkId !== "0x13881") {
          setNetwork(false);
        } else {
          setNetwork(true);
        }
      });
      window.ethereum.on("accountsChanged", (accounts) => {
        console.log(accounts);
      });
    }
  }, []);

  return (
    <div className="App">
      <ForgeNav
        address={user}
        loadData={loadData}
        isValidNetwork={isValidNetwork}
      />
      <header className="App-header">
        {user ? <Forge contract={contract} user={user} /> : <NoWallet />}
      </header>
    </div>
  );
}

export default App;
