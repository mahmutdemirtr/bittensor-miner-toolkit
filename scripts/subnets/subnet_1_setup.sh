#!/bin/bash
set -e

# Get wallet name from parameter or environment variable
WALLET_NAME="${1:-$WALLET_NAME}"

if [ -z "$WALLET_NAME" ]; then
    echo "ERROR: Wallet name is required"
    echo "Usage: $0 <wallet_name>"
    echo "   or: export WALLET_NAME=<wallet_name> && $0"
    exit 1
fi

echo "=== Installing Subnet 1: Apex (Competition-Based Mining) ==="
echo "Wallet: $WALLET_NAME"

# Use /workspace for pod-restart safety
WORKSPACE_DIR="/workspace/prompting"
SYMLINK_DIR="$HOME/prompting"

# Clone repo to /workspace if not exists
if [ ! -d "$WORKSPACE_DIR" ]; then
    cd /workspace
    git clone https://github.com/macrocosm-os/prompting.git
    echo "Repo cloned to /workspace/prompting"
else
    echo "Repo already exists at /workspace/prompting"
fi

# Create symlink from home to workspace
if [ ! -L "$SYMLINK_DIR" ]; then
    ln -sf "$WORKSPACE_DIR" "$SYMLINK_DIR"
    echo "Symlink created: ~/prompting -> /workspace/prompting"
fi

# Install Apex CLI
cd "$WORKSPACE_DIR"
echo "Installing Apex CLI..."

# Check if install_cli.sh exists
if [ -f "./install_cli.sh" ]; then
    # Remove stale egg-info if exists
    rm -rf src/apex.egg-info

    # Run the installer
    ./install_cli.sh
    echo "Apex CLI installed"
else
    echo "install_cli.sh not found, trying pip install..."
    source /workspace/bittensor-venv/bin/activate
    pip install -e . --quiet
fi

# Configure PATH for Apex CLI
echo ""
echo "Configuring Apex CLI PATH..."
if ! grep -q '/root/.local/bin' ~/.bashrc; then
    echo 'export PATH="/root/.local/bin:$PATH"' >> ~/.bashrc
    echo "PATH added to ~/.bashrc"
fi

export PATH="/root/.local/bin:$PATH"

# Create or update Apex config
CONFIG_FILE="$WORKSPACE_DIR/.apex.config.json"
echo "Creating/updating Apex config..."
cat > "$CONFIG_FILE" << EOF
{
  "hotkey_file_path": "/workspace/.bittensor/wallets/$WALLET_NAME/hotkeys/default",
  "timeout": 60.0
}
EOF
echo "Apex config updated: $CONFIG_FILE"

# Verify installation
echo ""
echo "Verifying Apex CLI installation..."
if command -v apex &> /dev/null; then
    APEX_VERSION=$(apex version 2>&1 | grep -oP 'v\d+\.\d+\.\d+' || echo "unknown")
    echo "Apex CLI $APEX_VERSION installed successfully"
else
    echo "Apex CLI not found in PATH, but installed locally"
    echo "Run: export PATH=\"/root/.local/bin:\$PATH\""
fi

echo ""
echo "============================================"
echo "Subnet 1 (Apex) Setup Complete!"
echo "============================================"
echo "  Repo: /workspace/prompting"
echo "  Config: /workspace/prompting/.apex.config.json"
echo "  Symlink: ~/prompting"
echo ""
echo "Next Steps:"
echo "  1. export PATH=\"/root/.local/bin:\$PATH\""
echo "  2. cd /workspace/prompting"
echo "  3. apex dashboard"
echo "  4. apex competitions"
echo "  5. apex submit"
echo ""
echo "NOTE: Subnet 1 uses competition-based mining"
echo "Traditional miner.py will NOT work!"
echo "Use 'apex submit' to participate in competitions."
echo ""
