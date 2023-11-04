import { useCallback, useEffect, useState } from "react";
import { Stack, Container } from "react-bootstrap";
import TokenCard from "./TokenCard";

const TotalTokens = 7;
// note: could have been in nfts metadata
const tokensDesc = {
  0: {
    name: "Gold",
    description: "Gold is a rare currency",
  },
  1: {
    name: "Silver",
    description: "Silver is a not common currency",
  },
  2: {
    name: "Bronze",
    description: "Bronze is a common currency",
  },
  3: {
    name: "Thor Hammer",
    description: "Thor hammered is forged from Gold and Silver",
  },
  4: {
    name: "Oblivion Sword",
    description: "Oblivion Sword is forged from Silver and Bronze",
  },
  5: {
    name: "Captain America Shield",
    description: "Captain America Shield is forged from Gold and Bronze",
  },
  6: {
    name: "Dante's Key",
    description: "Dante's Key is forged from Gold, Silver and Bronze",
  },
};

function Forge({ contract, user }) {
  const [tokens, setTokens] = useState([]);

  const mint = useCallback(
    async (tokenId) => {
      try {
        if (contract !== null && user !== null) {
          const trx = await contract.mintToken(tokenId);
          await trx.wait();
          console.log(trx);
          const totalTokens = await contract.balanceOfBatch(
            Array(TotalTokens).fill(user),
            [0, 1, 2, 3, 4, 5, 6]
          );
          setTokens((current) => {
            const newTokens = [...current];
            totalTokens.forEach((totalToken, index) => {
              newTokens[index].totalTokens = totalToken.toNumber();
            });
            return newTokens;
          });
        }
      } catch (error) {
        console.log(error);
        alert("error while minting please try again");
      }
    },
    [contract, user]
  );

  const getIPFSFromIPFSMetaData = useCallback((ipfsUrl) => {
    const url = ipfsUrl.replace("ipfs://", "https://ipfs.io/ipfs/");
    return fetch(url)
      .then((res) => res.json())
      .then((data) => data.image);
  }, []);

  useEffect(() => {
    if (contract != null && user != null) {
      async function fetchData() {
        try {
          // should be
          for (let i = 0; i < TotalTokens; i++) {
            const url = await contract.uri(i);
            const totalTokens = await contract.balanceOf(user, i);
            const imageUrl = await getIPFSFromIPFSMetaData(url);
            const token = {
              name: tokensDesc[i].name,
              description: tokensDesc[i].description,
              ipfsImageUrl: imageUrl,
              totalTokens: totalTokens.toNumber(),
            };
            setTokens((current) => [...current, token]);
          }
        } catch (error) {
          console.log(error);
        }
      }
      fetchData();
    }
  }, [contract, getIPFSFromIPFSMetaData, user]);

  return (
    <Container>
      <h1>Forge</h1>
      <Stack direction="horizontal" gap={3} className="flex-wrap">
        {tokens.map((token, index) => (
          <TokenCard
            key={index}
            name={token.name}
            description={token.description}
            ipfsImageUrl={token.ipfsImageUrl}
            totalTokens={token.totalTokens}
            onMint={() => mint(index)}
          />
        ))}
      </Stack>
    </Container>
  );
}

export default Forge;
