use bitcoincore_rpc::{Auth, Client as BitcoinClient, RpcApi};
use reqwest::blocking::Client;
use serde_json::Value;

/// Call Alice's Lightning node via CLN REST API on port 3010
fn call_alice_ln(method: &str, params: Value) -> Result<Value, Box<dyn std::error::Error>> {
    let rune = std::env::var("ALICE_RUNE")?;
    let url = format!("http://localhost:3010/v1/{}", method);

    let client = Client::new();
    let response = client
        .post(&url)
        .json(&params)
        .header("Rune", rune)
        .send()?
        .json::<Value>()?;

    Ok(response)
}

/// Call Bob's Lightning node via CLN REST API on port 3011
fn call_bob_ln(method: &str, params: Value) -> Result<Value, Box<dyn std::error::Error>> {
    let rune = std::env::var("BOB_RUNE")?;
    let url = format!("http://localhost:3011/v1/{}", method);

    let client = Client::new();
    let response = client
        .post(&url)
        .json(&params)
        .header("Rune", rune)
        .send()?
        .json::<Value>()?;

    Ok(response)
}

/// Call Carols's Lightning node via CLN REST API on port 3012
fn call_carol_ln(method: &str, params: Value) -> Result<Value, Box<dyn std::error::Error>> {
    let rune = std::env::var("CAROL_RUNE")?;
    let url = format!("http://localhost:3012/v1/{}", method);

    let client = Client::new();
    let response = client
        .post(&url)
        .json(&params)
        .header("Rune", rune)
        .send()?
        .json::<Value>()?;

    Ok(response)
}
fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Bitcoin RPC client
    let bitcoin_rpc = BitcoinClient::new(
        "http://localhost:18443",
        Auth::UserPass("alice".to_string(), "password".to_string()),
    )?;

    println!("Blockchain Info: {:?}", bitcoin_rpc.get_blockchain_info()?);
    // Get Alice's node info
    let alice_info = call_alice_ln("getinfo", Value::Null)?;
    println!("Alice Node Info: {:?}", alice_info);

    // Get Bob's node info
    let bob_info = call_bob_ln("getinfo", Value::Null)?;
    println!("Bob Node Info: {:?}", bob_info);


    // Get Carol's node info
    let carol_info = call_carol_ln("getinfo", Value::Null)?;
    println!("Carol Node Info: {:?}", carol_info);

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

    Ok(())
}
