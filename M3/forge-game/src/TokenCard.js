import Button from "react-bootstrap/Button";
import Card from "react-bootstrap/Card";
const getImageUrl = (ipfsUrl) =>
  ipfsUrl.replace("ipfs://", "https://ipfs.io/ipfs/");

function TokenCard({ ipfsImageUrl, name, description, onMint, totalTokens }) {
  return (
    <Card style={{ width: "18rem" }}>
      <Card.Img
        variant="top"
        src={getImageUrl(ipfsImageUrl)}
        width={100}
        height={100}
      />
      <Card.Body>
        <Card.Title>{name}</Card.Title>
        <Card.Text style={{ fontSize: "16px" }}>{description}</Card.Text>
        <Card.Title> Total Tokens: {totalTokens}</Card.Title>
        <Button variant="primary" onClick={onMint}>
          Mint
        </Button>
      </Card.Body>
    </Card>
  );
}

export default TokenCard;
