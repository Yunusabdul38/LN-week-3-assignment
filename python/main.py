import requests
import os
from bitcoinrpc.authproxy import AuthServiceProxy, JSONRPCException


def call_alice_ln(method, params=None):
    """Call Alice's Lightning node via CLN REST API on port 3010"""
    rune = os.environ.get('ALICE_RUNE')
    url = f'http://localhost:3010/v1/{method}'
    response = requests.post(
        url,
        json=params or {},
        headers={'Rune': rune}
    )
    return response.json()


def call_bob_ln(method, params=None):
    """Call Bob's Lightning node via CLN REST API on port 3011"""
    rune = os.environ.get('BOB_RUNE')
    url = f'http://localhost:3011/v1/{method}'
    response = requests.post(
        url,
        json=params or {},
        headers={'Rune': rune}
    )
    return response.json()

def call_carol_ln(method, params=None):
    """Call Carol's Lightning node via CLN REST API on port 3012"""
    rune = os.environ.get('CAROL_RUNE')
    url = f'http://localhost:3012/v1/{method}'
    response = requests.post(
        url,
        json=params or {},
        headers={'Rune': rune}
    )
    return response.json()

def main():

    try:
        # Bitcoin RPC client
        bitcoin_rpc = AuthServiceProxy("http://alice:password@localhost:18443")
        print("Blockchain Info:", bitcoin_rpc.getblockchaininfo())

        # Get Alice's node info
        alice_info = call_alice_ln("getinfo")
        print("Alice Node Info:", alice_info)

        # Get Bob's node info
        bob_info = call_bob_ln("getinfo")
        print("Bob Node Info:", bob_info)

        # Get Carol's node info
        carol_info = call_carol_ln("getinfo")
        print("Carol Node Info:", carol_info)

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

        # Carol generates a 100,000 sat invoice with label "multihop_<timestamp>" and description "Multi-Hop Payment"

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

    except JSONRPCException as e:
        print("An error occurred", e)

if __name__ == "__main__":
    main()
