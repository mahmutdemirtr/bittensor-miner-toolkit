#!/bin/bash
set -e

echo "=== Installing Subnet 18: Cortex.t (LLM) ==="

# Clone repo
if [ ! -d ~/cortex.t ]; then
    cd ~
    git clone https://github.com/corcel-api/cortex.t.git
    echo " Repo cloned"
else
    echo " Repo already exists"
fi

# Install dependencies
cd ~/cortex.t
source ~/bittensor-venv/bin/activate
pip install -r requirements.txt --quiet
pip install -e . --quiet

echo ""
echo " Subnet 18 (Cortex.t) installed successfully"
echo "   Repo: ~/cortex.t"
echo "   Miner: neurons/miner.py"
echo ""
