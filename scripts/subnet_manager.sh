#!/bin/bash
set -e

SUBNET_ID=$1
WALLET_NAME=$2

if [ -z "$SUBNET_ID" ]; then
    echo "Usage: subnet_manager.sh <subnet_id> [wallet_name]"
    exit 1
fi

echo "=== Subnet Manager ==="
echo "Target Subnet: $SUBNET_ID"
echo ""

# Supported subnets
SUPPORTED_SUBNETS=(1 3 8 18 21)

# Check if subnet is supported
if [[ ! " ${SUPPORTED_SUBNETS[@]} " =~ " ${SUBNET_ID} " ]]; then
    echo "❌ ERROR: Subnet $SUBNET_ID is not supported"
    echo ""
    echo "Supported subnets:"
    echo "  1  - Text Prompting"
    echo "  3  - Data Vending"
    echo "  8  - Taoshi (Financial Prediction)"
    echo "  18 - Cortex.t (LLM)"
    echo "  21 - FileTAO (Storage)"
    exit 1
fi

# Setup script path
SETUP_SCRIPT="$(dirname $0)/subnets/subnet_${SUBNET_ID}_setup.sh"

if [ ! -f "$SETUP_SCRIPT" ]; then
    echo "❌ ERROR: Setup script not found: $SETUP_SCRIPT"
    exit 1
fi

# Run setup
echo "Running setup for subnet $SUBNET_ID..."
echo ""
if [ -n "$WALLET_NAME" ]; then
    bash "$SETUP_SCRIPT" "$WALLET_NAME"
else
    bash "$SETUP_SCRIPT"
fi

echo ""
echo "✅ Subnet $SUBNET_ID setup completed"
