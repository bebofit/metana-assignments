import Container from "react-bootstrap/Container";

function NoWallet() {
  return (
    <Container>
      <h1>Wallet Not Connected</h1>
      <p>
        No wallet was connected. Please make sure you have conencted your wallet
        to buy tokens
      </p>
    </Container>
  );
}

export default NoWallet;
