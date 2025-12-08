#!/bin/bash
set -e

echo "=== Installing Subnet 21: FileTAO (Decentralized Storage) ==="

# Clone repo
if [ ! -d ~/storage-subnet ]; then
    cd ~
    git clone https://github.com/ifrit98/storage-subnet.git
    echo " Repo cloned"
else
    echo " Repo already exists"
fi

# Install dependencies
cd ~/storage-subnet
source ~/bittensor-venv/bin/activate
pip install -r requirements.txt --quiet
pip install -e . --quiet

echo ""
echo " Subnet 21 (FileTAO) installed successfully"
echo "   Repo: ~/storage-subnet"
echo "   Miner: neurons/miner.py"
echo ""
