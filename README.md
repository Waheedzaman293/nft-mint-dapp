# LuxeNFT — NFT Mint dApp (sample)

A complete, minimal **NFT minting dApp**: an ERC-721 contract plus a small
wallet-connect web frontend.

## What's inside
- `contracts/LuxeNFT.sol` — self-contained ERC-721 (Solidity `^0.8.20`):
  paid public mint, 1,000 max supply, 5 per wallet, base-URI metadata,
  owner controls (open/close mint, price, withdraw)
- `frontend/` — plain HTML + ethers.js page: connect wallet (MetaMask),
  live supply/price display, quantity picker, mint button with status updates

## Run it
1. Deploy `LuxeNFT.sol` on a testnet (e.g. Sepolia or BNB testnet) via Remix,
   passing your metadata base URI, e.g. `ipfs://YOUR_CID/`
2. Call `setMintOpen(true)` from the owner wallet
3. Put the contract address in `frontend/app.js` (`CONTRACT_ADDRESS`)
4. Open `frontend/index.html` in a browser and mint

## Notes
Portfolio sample for demonstration. Gas fees are always paid from the
user's own wallet; private keys are never handled by the dApp.
For production use, get an independent security review first.
