// LuxeNFT mint dApp — frontend logic (ethers.js v5)
// 1. Deploy contracts/LuxeNFT.sol (Remix/Hardhat)
// 2. Paste the deployed contract address below
// 3. Open index.html in a browser with MetaMask installed

const CONTRACT_ADDRESS = "0xYourDeployedContractAddress";

const ABI = [
  "function mint(uint256 quantity) payable",
  "function totalSupply() view returns (uint256)",
  "function mintPrice() view returns (uint256)",
  "function mintOpen() view returns (bool)",
  "function balanceOf(address account) view returns (uint256)"
];

let provider, signer, contract;

const statusEl = document.getElementById("status");
const supplyEl = document.getElementById("supply");
const mintBtn = document.getElementById("mintBtn");

function setStatus(msg) {
  statusEl.textContent = msg;
}

async function refreshSupply() {
  if (!contract) return;
  const [supply, price] = await Promise.all([contract.totalSupply(), contract.mintPrice()]);
  supplyEl.textContent = `Supply: ${supply} / 1000 · Price: ${ethers.utils.formatEther(price)} ETH`;
}

document.getElementById("connectBtn").addEventListener("click", async () => {
  if (!window.ethereum) {
    setStatus("Please install MetaMask first.");
    return;
  }
  try {
    await window.ethereum.request({ method: "eth_requestAccounts" });
    provider = new ethers.providers.Web3Provider(window.ethereum);
    signer = provider.getSigner();
    contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);
    const address = await signer.getAddress();
    setStatus(`Connected: ${address.slice(0, 6)}...${address.slice(-4)}`);
    mintBtn.disabled = false;
    await refreshSupply();
  } catch (err) {
    setStatus("Connection rejected.");
  }
});

mintBtn.addEventListener("click", async () => {
  const qty = parseInt(document.getElementById("qty").value, 10);
  if (!contract || !qty || qty < 1) return;
  try {
    const price = await contract.mintPrice();
    setStatus("Confirm the transaction in your wallet...");
    const tx = await contract.mint(qty, { value: price.mul(qty) });
    setStatus("Minting... waiting for confirmation.");
    await tx.wait();
    setStatus(`Minted ${qty} NFT(s). Thank you!`);
    await refreshSupply();
  } catch (err) {
    setStatus("Mint failed: " + (err.data?.message || err.message || "unknown error"));
  }
});
