#!/bin/bash
set -e

echo "============================================"
echo "  Apex Dashboard Launcher"
echo "============================================"
echo ""

# Configure PATH
export PATH="/root/.local/bin:$PATH"

# Get wallet name from terraform.tfvars
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"
WALLET_NAME=$(grep -E '^wallet_name\s*=' "$TERRAFORM_DIR/terraform.tfvars" | sed -E 's/.*=\s*"([^"]+)".*/\1/')

if [ -z "$WALLET_NAME" ]; then
    echo "ERROR: Could not read wallet_name from terraform.tfvars"
    exit 1
fi

echo "Wallet: $WALLET_NAME"
echo ""

# Check if Apex CLI is available
if ! command -v apex &> /dev/null; then
    echo "ERROR: Apex CLI not found!"
    echo ""
    echo "Please install Apex CLI first:"
    echo "  cd /workspace/bittensor-miner-toolkit"
    echo "  ./scripts/subnet_manager.sh 1"
    echo ""
    exit 1
fi

# Check if in prompting directory
if [ ! -d "/workspace/prompting" ]; then
    echo "ERROR: Prompting directory not found!"
    echo ""
    echo "Please install Subnet 1 (Apex) first:"
    echo "  ./scripts/subnet_manager.sh 1"
    echo ""
    exit 1
fi

# Change to prompting directory
cd /workspace/prompting

# Check config
if [ ! -f ".apex.config.json" ]; then
    echo "WARNING: No .apex.config.json found"
    echo "Creating default config..."
    cat > .apex.config.json << EOF
{
  "hotkey_file_path": "/workspace/.bittensor/wallets/$WALLET_NAME/hotkeys/default",
  "timeout": 60.0
}
EOF
    echo "Config created!"
    echo ""
fi

# Show status
echo "Apex CLI Status:"
APEX_VERSION=$(apex version 2>&1 | grep -oP 'v\d+\.\d+\.\d+' || echo "unknown")
echo "  Version: $APEX_VERSION"
echo "  Config: .apex.config.json"
echo "  Directory: /workspace/prompting"
echo ""

# Show competitions
echo "Active Competitions:"
apex competitions 2>/dev/null || echo "  Unable to fetch competitions"
echo ""

echo "============================================"
echo "  Launching Apex Dashboard..."
echo "============================================"
echo ""
echo "Navigation:"
echo "  ↑↓ - Move between competitions"
echo "  ENTER - View details"
echo "  q/ESC - Exit dashboard"
echo ""

# Launch dashboard
apex dashboard
