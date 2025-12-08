#!/bin/bash
set -e

SUBNET_ID=$1
WALLET_NAME=$2

echo "=== Starting Bittensor Miner ==="
echo "Subnet ID: $SUBNET_ID"
echo "Wallet: $WALLET_NAME"

# Check if Subnet 1 (Apex - Competition-based)
if [ "$SUBNET_ID" = "1" ]; then
    echo ""
    echo "============================================"
    echo "  SUBNET 1 USES APEX CLI!"
    echo "============================================"
    echo ""
    echo "Subnet 1 is competition-based and does NOT use"
    echo "traditional miner. Please use Apex CLI instead:"
    echo ""
    echo "  1. export PATH=\"/root/.local/bin:\$PATH\""
    echo "  2. cd /workspace/prompting"
    echo "  3. apex dashboard"
    echo "  4. apex competitions"
    echo "  5. apex submit"
    echo ""
    echo "Docs: https://docs.macrocosmos.ai/subnets/new-subnet-1-apex"
    echo ""
    echo "============================================"
    exit 0
fi

# Activate venv
source ~/bittensor-venv/bin/activate

# Create log directory
mkdir -p /var/log/bittensor

# Kill any existing miner
echo "Stopping any existing miner..."
pkill -f "python.*bittensor" || true
sleep 2

# Start miner
echo "Starting miner..."
nohup python -m bittensor.miner \
    --netuid $SUBNET_ID \
    --wallet.name $WALLET_NAME \
    --wallet.hotkey default \
    --logging.debug \
    --axon.port 8091 \
    > /var/log/bittensor/miner.log 2>&1 &

MINER_PID=$!
echo $MINER_PID > /var/run/bittensor-miner.pid

echo ""
echo "✅ Miner started with PID: $MINER_PID"
echo ""
echo "Check logs: tail -f /var/log/bittensor/miner.log"
echo "Check status: ps -p $MINER_PID"
echo ""
echo "=== Miner Started ==="
