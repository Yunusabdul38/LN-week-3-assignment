#!/bin/bash
source bash/helper.sh

# Get blockchain info using bitcoin-cli
blockchain_info=$(bitcoin_cli getblockchaininfo)

# Print the blockchain info
echo "Blockchain Info: $blockchain_info"

alice_info=$(alice_ln_cli getinfo)
echo "Alice Node Info: $alice_info"

bob_info=$(bob_ln_cli getinfo)
echo "Bob Node Info: $bob_info"

carol_info=$(carol_ln_cli getinfo)
echo "Carol Node Info: $carol_info"

# Create a bitcoin wallet named 'mining_wallet' if it doesn't exist

# Generate a mining address and mine initial blocks

# Create and fund an on-chain address for Alice

# Create and fund an on-chain address for Bob

# Mine blocks to confirm funding transactions

# Verify Alice's on-chain balance

# Verify Bob's on-chain balance

# Get node IDs for Alice, Bob, and Carol

# Connect them as peers

# Alice opens a 500,000 sat channel with Bob

# Bob opens a 300,000 sat channel with Carol

# Mine at least 6 blocks to confirm channels

# Wait for channels to reach CHANNELD_NORMAL state

# Carol generates a 100,000 sat invoice with label "multihop_$(date +%s)" and description "Multi-Hop Payment"

# Extract the BOLT11 string and payment hash from the invoice

# Alice pays Carol's BOLT11 invoice (routed through Bob)

# Extract payment preimage and status

# Verify Alice's balance decreased

# Verify Carol's balance increased

# Verify Bob's balance. Is there any difference? Why is it?

# Verify Bob forwarded the payment using listforwards and extract payment_hash from it

# Write to out.txt:
# Payment Hash
# Payment Preimage
# BOLT11 Invoice
# Payer_ID
# Payee_ID
# Fee_msat
# Payment_Hash from Bob's forwarded payment
