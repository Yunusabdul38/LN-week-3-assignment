#!/bin/bash
# Setup nvm and install pre-req
if command -v node > /dev/null 2>&1; then
  echo "Node.js is already installed. Current version: $(node -v)"
else
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  source $HOME/.nvm/nvm.sh
  nvm install --lts
fi

if ! grep -q "# /bin/bash ./python/run-python.sh" run.sh; then
  if command -v python3 > /dev/null 2>&1; then
    echo "Python3 is already installed. Current version: $(python3 --version)"
  else
    echo "Installing Python3..."
    sudo apt-get update && sudo apt-get install -y python3 python3-pip python3-venv
  fi
  # Install Python dependencies
  echo "Installing Python dependencies..."
  python3 -m pip install requests python-bitcoinrpc
fi

if ! grep -q "# /bin/bash ./rust/run-rust.sh" run.sh; then
  if command -v cargo > /dev/null 2>&1; then
    echo "Cargo is already installed. Current version: $(cargo --version)"
  else
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env
  fi
fi

npm install # Install Node.js dependencies

set -e  # Exit immediately if any command fails

# Give access to all runners

chmod +x ./bash/run-bash.sh
chmod +x ./python/run-python.sh
chmod +x ./javascript/run-javascript.sh
chmod +x ./rust/run-rust.sh
chmod +x ./run.sh

# Start docker
docker compose up -d
echo " Docker started."

sleep 5
export ALICE_RUNE=$(docker exec alice lightning-cli --network=regtest createrune restrictions='[]' | grep -o '"rune": "[^"]*"' | cut -d'"' -f4)
export BOB_RUNE=$(docker exec bob lightning-cli --network=regtest createrune restrictions='[]' | grep -o '"rune": "[^"]*"' | cut -d'"' -f4)
export CAROL_RUNE=$(docker exec carol lightning-cli --network=regtest createrune restrictions='[]' | grep -o '"rune": "[^"]*"' | cut -d'"' -f4)

# Run the test scripts
/bin/bash run.sh
npm run test

# Stop Docker services
docker compose down -v
echo "Docker services stopped."
