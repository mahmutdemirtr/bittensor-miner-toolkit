#!/bin/bash
set -e

# Usage: ./setup_wallet.sh <mode> <wallet_name>
# mode: create | import
# wallet_name: name for the wallet

MODE=$1
WALLET_NAME=$2

if [ -z "$MODE" ] || [ -z "$WALLET_NAME" ]; then
    echo "Usage: $0 <mode> <wallet_name>"
    echo "  mode: create | import"
    echo "  wallet_name: name for the wallet"
    exit 1
fi

if [ "$MODE" != "create" ] && [ "$MODE" != "import" ]; then
    echo "ERROR: Mode must be 'create' or 'import'"
    exit 1
fi

echo "=== Bittensor Wallet Setup Started ==="
echo "Mode: $MODE"
echo "Wallet Name: $WALLET_NAME"
echo ""

# Activate virtual environment
source ~/bittensor-venv/bin/activate

if [ "$MODE" = "import" ]; then
    # Import mode - requires mnemonic environment variables
    if [ -z "$COLDKEY_MNEMONIC" ] || [ -z "$HOTKEY_MNEMONIC" ]; then
        echo "ERROR: COLDKEY_MNEMONIC and HOTKEY_MNEMONIC environment variables must be set for import mode"
        exit 1
    fi

    echo "Importing wallet from mnemonic..."

    # Create Python script to import wallet
    python3 << EOF
import bittensor as bt

# Create wallet instance with correct path
wallet = bt.wallet(name="$WALLET_NAME", path="/workspace/.bittensor/wallets")

# Import coldkey from mnemonic
print("Importing coldkey...")
wallet.create_coldkey_from_uri(
    uri="$COLDKEY_MNEMONIC",
    use_password=False,
    overwrite=True,
    suppress=False
)

# Import hotkey from mnemonic
print("Importing hotkey...")
wallet.create_hotkey_from_uri(
    uri="$HOTKEY_MNEMONIC",
    use_password=False,
    overwrite=True,
    suppress=False
)

print("\nWallet imported successfully")
print(f"Wallet name: {wallet.name}")
print(f"Coldkey address: {wallet.get_coldkeypub().ss58_address}")
print(f"Hotkey address: {wallet.get_hotkey().ss58_address}")
EOF

elif [ "$MODE" = "create" ]; then
    # Create mode - generates new mnemonic
    echo "Creating new wallet..."

    python3 << EOF
import bittensor as bt

# Create wallet instance with correct path
wallet = bt.wallet(name="$WALLET_NAME", path="/workspace/.bittensor/wallets")

# Create new coldkey and hotkey
print("Creating coldkey and hotkey...")
wallet.create(
    coldkey_use_password=False,
    hotkey_use_password=False,
    overwrite=True,
    suppress=False
)

print("\nWallet created successfully")
print(f"Wallet name: {wallet.name}")
print(f"Coldkey address: {wallet.get_coldkeypub().ss58_address}")
print(f"Hotkey address: {wallet.get_hotkey().ss58_address}")

print("\n⚠️  IMPORTANT: Save your mnemonic phrases in a secure location!")
EOF

fi

echo ""
echo "=== Bittensor Wallet Setup Complete ==="
echo "Wallet location: /workspace/.bittensor/wallets/$WALLET_NAME"
