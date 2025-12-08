#!/bin/bash

echo "========================================"
echo "  Bittensor Miner Status"
echo "========================================"
echo ""

# Check if miner is running
if [ -f /var/run/bittensor-miner.pid ]; then
    PID=$(cat /var/run/bittensor-miner.pid)
    if ps -p $PID > /dev/null 2>&1; then
        echo "✅ Status: RUNNING"
        echo "   PID: $PID"

        # Get uptime
        START_TIME=$(ps -p $PID -o lstart=)
        echo "   Started: $START_TIME"

        # Memory usage
        MEM=$(ps -p $PID -o rss= | awk '{print $1/1024 " MB"}')
        echo "   Memory: $MEM"
    else
        echo "❌ Status: STOPPED (stale PID file)"
        rm -f /var/run/bittensor-miner.pid
    fi
else
    echo "❌ Status: NOT STARTED"
fi

echo ""
echo "----------------------------------------"
echo "GPU Status:"
echo "----------------------------------------"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=index,name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits | while IFS=',' read -r index name temp util mem_used mem_total; do
        echo "GPU $index: $name"
        echo "   Temperature: ${temp}°C"
        echo "   Utilization: ${util}%"
        echo "   Memory: ${mem_used}MB / ${mem_total}MB"
    done
else
    echo "❌ nvidia-smi not found"
fi

echo ""
echo "----------------------------------------"
echo "Wallet Status:"
echo "----------------------------------------"
if [ -d ~/.bittensor/wallets ]; then
    WALLET_COUNT=$(ls -1 ~/.bittensor/wallets | wc -l)
    echo "Wallets found: $WALLET_COUNT"
    ls -1 ~/.bittensor/wallets | while read wallet; do
        echo "   - $wallet"
    done
else
    echo "❌ No wallets found"
fi

echo ""
echo "----------------------------------------"
echo "Recent Logs (last 10 lines):"
echo "----------------------------------------"
if [ -f /var/log/bittensor/miner.log ]; then
    tail -10 /var/log/bittensor/miner.log
else
    echo "❌ No log file found"
fi

echo ""
echo "========================================"
