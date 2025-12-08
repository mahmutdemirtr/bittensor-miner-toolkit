#!/bin/bash
set -e

echo "=== Installing Subnet 8: Taoshi (Financial Prediction) ==="

# Clone repo
if [ ! -d ~/taoshi ]; then
    cd ~
    git clone https://github.com/taoshidev/time-series-prediction-subnet.git taoshi
    echo " Repo cloned"
else
    echo " Repo already exists"
fi

# Install dependencies
cd ~/taoshi
source ~/bittensor-venv/bin/activate
pip install -r requirements.txt --quiet
pip install -e . --quiet

echo ""
echo " Subnet 8 (Taoshi) installed successfully"
echo "   Repo: ~/taoshi"
echo "   Miner: neurons/miner.py"
echo ""
