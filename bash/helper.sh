#!/bin/bash
bitcoin_cli () {
  docker exec bitcoind bitcoin-cli -regtest -rpcuser=alice -rpcpassword=password "$@"
}

alice_ln_cli () {
  docker exec alice lightning-cli --network=regtest "$@"
}

bob_ln_cli () {
  docker exec bob lightning-cli --network=regtest "$@"
}

carol_ln_cli () {
  docker exec carol lightning-cli --network=regtest "$@"
}
