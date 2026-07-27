const fs = require("fs").promises;
const axios = require("axios");
const bitcoin = require("bitcoin-core");

// Call Alice's Lightning node via CLN REST API on port 3010
async function callAliceLn(method, params = {}) {
  const response = await axios.post(
    `http://localhost:3010/v1/${method}`,
    params,
    { headers: { Rune: process.env.ALICE_RUNE } },
  );
  return response.data;
}

// Call Bob's Lightning node via CLN REST API on port 3011
async function callBobLn(method, params = {}) {
  const response = await axios.post(
    `http://localhost:3011/v1/${method}`,
    params,
    { headers: { Rune: process.env.BOB_RUNE } },
  );
  return response.data;
}

// Call Carol's Lightning node via CLN REST API on port 3012
async function callCarolLn(method, params = {}) {
  const response = await axios.post(
    `http://localhost:3012/v1/${method}`,
    params,
    { headers: { Rune: process.env.CAROL_RUNE } },
  );
  return response.data;
}

async function main() {
  // Example: Get blockchain info and lightning node info
  const bitcoinClient = new bitcoin({
    network: "regtest",
    username: "alice",
    password: "password",
    port: 18443,
  });

  console.log("Bitcoin Node Info:", await bitcoinClient.getBlockchainInfo());

  const alice_info = await callAliceLn("getinfo");
  console.log("Alice Node Info:", alice_info);

  const bob_info = await callBobLn("getinfo");
  console.log("Bob Node Info:", bob_info);

  const carol_info = await callCarolLn("getinfo");
  console.log("Carol Node Info:", carol_info);

  // Create a bitcoin wallet named 'mining_wallet' if it doesn't exist

  // Generate a mining address and mine initial blocks

  // Create and fund an on-chain address for Alice

  // Create and fund an on-chain address for Bob

  // Mine blocks to confirm funding transactions

  // Verify Alice's on-chain balance

  // Verify Bob's on-chain balance

  // Get node IDs for Alice, Bob, and Carol

  // Connect them as peers

  // Alice opens a 500,000 sat channel with Bob

  // Bob opens a 300,000 sat channel with Carol

  // Mine at least 6 blocks to confirm channels

  // Wait for channels to reach CHANNELD_NORMAL state

  // Carol generates a 100,000 sat invoice with label "multihop_<timestamp>" and description "Multi-Hop Payment"

  // Extract the BOLT11 string and payment hash from the invoice

  // Alice pays Carol's BOLT11 invoice (routed through Bob)

  // Extract payment preimage and status

  // Verify Alice's balance decreased

  // Verify Carol's balance increased

  // Verify Bob's balance. Is there any difference? Why is it?

  // Verify Bob forwarded the payment using listforwards and extract payment_hash from it

  // Write to out.txt:
  // Payment Hash
  // Payment Preimage
  // BOLT11 Invoice
  // Payer_ID
  // Payee_ID
  // Fee_msat
  // Payment_Hash from Bob's forwarded payment
}

main().catch(err => {
    console.error('Error:', err);
    process.exit(1);
});
