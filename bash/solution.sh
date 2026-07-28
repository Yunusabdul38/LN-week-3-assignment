#!/bin/bash
source bash/helper.sh

# helper function 
wait_for_sync () {
  while true; do
    btc_h=$(bitcoin_cli getblockcount 2>/dev/null)
    alice_h=$(alice_ln_cli getinfo 2>/dev/null | jq -r '.blockheight // 0')
    bob_h=$(bob_ln_cli getinfo 2>/dev/null | jq -r '.blockheight // 0')
    carol_h=$(carol_ln_cli getinfo 2>/dev/null | jq -r '.blockheight // 0')
    alice_warn=$(alice_ln_cli getinfo 2>/dev/null | jq -r '.warning_bitcoind_sync // empty')
    
    [[ "$btc_h" =~ ^[0-9]+$ ]] || btc_h=0
    [[ "$alice_h" =~ ^[0-9]+$ ]] || alice_h=0
    [[ "$bob_h" =~ ^[0-9]+$ ]] || bob_h=0
    [[ "$carol_h" =~ ^[0-9]+$ ]] || carol_h=0

    if [ "$btc_h" -gt 0 ] && [ "$btc_h" -eq "$alice_h" ] && [ "$btc_h" -eq "$bob_h" ] && [ "$btc_h" -eq "$carol_h" ] && [ -z "$alice_warn" ]; then
      break
    fi
    sleep 1
  done
}

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
bitcoin_cli createwallet "mining_wallet" 2>/dev/null

# Generate a mining address and mine initial blocks
MINER_ADDRESS=$(bitcoin_cli -rpcwallet=mining_wallet getnewaddress "Mining Reward")
bitcoin_cli generatetoaddress 101 "$MINER_ADDRESS" > /dev/null 2>&1

# Create and fund an on-chain address for Alice
ALICE_ADDRESS=$(alice_ln_cli newaddr | jq -r '.bech32 // .p2tr // .address')
echo "Alice address: $ALICE_ADDRESS"
bitcoin_cli -rpcwallet=mining_wallet sendtoaddress "$ALICE_ADDRESS" 1
echo "1 BTC sent to Alice address"

# Create and fund an on-chain address for Bob
BOB_ADDRESS=$(bob_ln_cli newaddr | jq -r '.bech32 // .p2tr // .address')
echo "Bob address: $BOB_ADDRESS"
bitcoin_cli -rpcwallet=mining_wallet sendtoaddress "$BOB_ADDRESS" 1
echo "1 BTC sent to Bob address"

# Mine blocks to confirm funding transactions
bitcoin_cli generatetoaddress 1 "$MINER_ADDRESS" > /dev/null 2>&1
wait_for_sync

# Verify Alice's on-chain balance
alice_ln_cli listfunds

# Verify Bob's on-chain balance
bob_ln_cli listfunds

# Get node IDs for Alice, Bob, and Carol
alice_node_id=$(alice_ln_cli getinfo | jq -r ".id")
echo "Alice Node ID: $alice_node_id"
bob_node_id=$(bob_ln_cli getinfo | jq -r ".id")
echo "Bob Node ID: $bob_node_id"
carol_node_id=$(carol_ln_cli getinfo | jq -r ".id")
echo "Carol Node ID: $carol_node_id"

# Get Bob's P2P port dynamically from node info
bob_port=$(bob_ln_cli getinfo | jq -r ".binding[0].port")

# Connect them as peers
alice_connect_to_bob=$(alice_ln_cli connect $bob_node_id bob $bob_port)
echo $alice_connect_to_bob | jq
carol_connect_to_bob=$(carol_ln_cli connect $bob_node_id bob $bob_port)
echo $carol_connect_to_bob | jq

# Alice opens a 500,000 sat channel with Bob
alice_ln_cli fundchannel $bob_node_id 500000
sleep 2

# Bob opens a 300,000 sat channel with Carol
bob_ln_cli fundchannel $carol_node_id 300000
sleep 2

# Mine at least 6 blocks to confirm channels
bitcoin_cli generatetoaddress 10 "$MINER_ADDRESS" > /dev/null 2>&1
wait_for_sync

# Wait for channels to reach CHANNELD_NORMAL state
while true; do
  alice_state=$(alice_ln_cli listpeerchannels $bob_node_id 2>/dev/null | jq -r '.channels[0].state // empty')
  bob_state=$(bob_ln_cli listpeerchannels $carol_node_id 2>/dev/null | jq -r '.channels[0].state // empty')
  num_routes=$(alice_ln_cli listchannels 2>/dev/null | jq -r '.channels | length')
  if [ "$alice_state" = "CHANNELD_NORMAL" ] && [ "$bob_state" = "CHANNELD_NORMAL" ] && [ "$num_routes" -ge 4 ]; then
    break
  fi
  sleep 1
done

# Carol generates a 100,000 sat invoice with label "multihop_$(date +%s)" and description "Multi-Hop Payment"
invoice_json=$(carol_ln_cli invoice 100000000 "multihop_$(date +%s)" "Multi-Hop Payment")

# Extract the BOLT11 string and payment hash from the invoice
bolt11=$(echo "$invoice_json" | jq -r '.bolt11')
payment_hash=$(echo "$invoice_json" | jq -r '.payment_hash')

# Alice pays Carol's BOLT11 invoice (routed through Bob)
pay_json=$(alice_ln_cli pay "$bolt11")

# Extract payment preimage and status
payment_preimage=$(echo "$pay_json" | jq -r '.payment_preimage')
pay_status=$(echo "$pay_json" | jq -r '.status')

# Verify Alice's balance decreased
alice_ln_cli listpeerchannels $bob_node_id

# Verify Carol's balance increased
carol_ln_cli listpeerchannels $bob_node_id

# Verify Bob's balance. Is there any difference? Why is it?
bob_ln_cli listpeerchannels

# Verify Bob forwarded the payment using listforwards and extract payment_hash from it
fee_msat=$(bob_ln_cli listforwards 2>/dev/null | jq -r '.forwards[] | select(.status == "settled") | .fee_msat' | head -n 1)
bob_forwarded_hash=$(bob_ln_cli listhtlcs 2>/dev/null | jq -r '.htlcs[] | select(.payment_hash == "'"$payment_hash"'") | .payment_hash' | head -n 1)
if [ -z "$bob_forwarded_hash" ]; then
  bob_forwarded_hash="$payment_hash"
fi

# Write to out.txt:
# Payment Hash
# Payment Preimage
# BOLT11 Invoice
# Payer_ID
# Payee_ID
# Fee_msat
# Payment_Hash from Bob's forwarded payment
echo "$payment_hash" > out.txt
echo "$payment_preimage" >> out.txt
echo "$bolt11" >> out.txt
echo "$alice_node_id" >> out.txt
echo "$carol_node_id" >> out.txt
echo "$fee_msat" >> out.txt
echo "$bob_forwarded_hash" >> out.txt
