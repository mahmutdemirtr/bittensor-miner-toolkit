#!/bin/bash
set -e

echo "=== Installing Subnet 3: Data Vending ==="

# Clone repo
if [ ! -d ~/data-universe ]; then
    cd ~
    git clone https://github.com/RusticLuftig/data-universe.git
    echo " Repo cloned"
else
    echo " Repo already exists"
fi

# Install dependencies
cd ~/data-universe
source ~/bittensor-venv/bin/activate
pip install -e . --quiet

echo ""
echo " Subnet 3 (Data Vending) installed successfully"
echo "   Repo: ~/data-universe"
echo "   Miner: neurons/miner.py"
echo ""
