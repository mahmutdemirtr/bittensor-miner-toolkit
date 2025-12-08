#!/bin/bash
# Smart Subnet Registration - Check, Auto-Register, or Report Issues

set -e

SUBNET_ID=$1
WALLET_NAME=$2

if [ -z "$SUBNET_ID" ] || [ -z "$WALLET_NAME" ]; then
    echo "Usage: $0 <subnet_id> <wallet_name>"
    exit 1
fi

echo "============================================"
echo "  Smart Subnet Registration"
echo "============================================"
echo "Subnet: $SUBNET_ID"
echo "Wallet: $WALLET_NAME"
echo ""

# Activate bittensor venv
source ~/bittensor-venv/bin/activate

# Main registration logic in Python
python3 << EOF
import bittensor as bt
import sys

try:
    # Load wallet
    print("📂 Loading wallet...")
    wallet = bt.Wallet(name="$WALLET_NAME", path="/workspace/.bittensor/wallets")
    print(f"   Coldkey: {wallet.coldkey.ss58_address}")
    print(f"   Hotkey: {wallet.hotkey.ss58_address}")
    print()
    
    # Connect to subtensor
    print("🔗 Connecting to Bittensor network (finney)...")
    subtensor = bt.Subtensor(network="finney")
    print("   ✅ Connected")
    print()
    
    # Check if already registered
    print(f"🔍 Checking registration on subnet $SUBNET_ID...")
    is_registered = subtensor.is_hotkey_registered(
        netuid=$SUBNET_ID,
        hotkey_ss58=wallet.hotkey.ss58_address
    )
    
    if is_registered:
        uid = subtensor.get_uid_for_hotkey_on_subnet(
            hotkey_ss58=wallet.hotkey.ss58_address,
            netuid=$SUBNET_ID
        )
        print(f"✅ ALREADY REGISTERED!")
        print(f"   Subnet: $SUBNET_ID")
        print(f"   UID: {uid}")
        print()
        print("=" * 44)
        print("  Ready to mine! ⛏️")
        print("=" * 44)
        sys.exit(0)
    
    print("❌ Not registered on subnet $SUBNET_ID")
    print()
    
    # Get subnet hyperparameters
    print("📊 Checking subnet parameters...")
    hyperparams = subtensor.get_subnet_hyperparameters(netuid=$SUBNET_ID)
    min_burn = hyperparams.min_burn / 1e9  # Convert from rao to TAO
    max_burn = hyperparams.max_burn / 1e9
    difficulty = hyperparams.difficulty
    
    print(f"   Min Burn: {min_burn:.4f} τ")
    print(f"   Max Burn: {max_burn:.4f} τ")
    print(f"   Difficulty: {difficulty:,}")
    print()
    
    # Check wallet balance
    print("💰 Checking wallet balance...")
    balance = subtensor.get_balance(wallet.coldkey.ss58_address)
    balance_tao = float(balance.tao)
    
    print(f"   Balance: {balance_tao:.4f} τ")
    print()
    
    # Check if balance is sufficient
    if balance_tao >= min_burn:
        print("✅ Balance is sufficient for registration!")
        print()
        print("🚀 Attempting automatic registration...")
        print(f"   This will burn ~{min_burn:.4f} τ from your wallet")
        print()
        
        # Attempt registration
        success = subtensor.burned_register(
            netuid=$SUBNET_ID,
            wallet=wallet,
            prompt=False  # No prompt, auto-approve
        )
        
        if success:
            uid = subtensor.get_uid_for_hotkey_on_subnet(
                hotkey_ss58=wallet.hotkey.ss58_address,
                netuid=$SUBNET_ID
            )
            print()
            print("=" * 44)
            print("  🎉 REGISTRATION SUCCESSFUL!")
            print("=" * 44)
            print(f"   Subnet: $SUBNET_ID")
            print(f"   UID: {uid}")
            print(f"   Burned: ~{min_burn:.4f} τ")
            print()
            
            # Check new balance
            new_balance = subtensor.get_balance(wallet.coldkey.ss58_address)
            print(f"   New Balance: {float(new_balance.tao):.4f} τ")
            print()
            print("=" * 44)
            print("  Ready to mine! ⛏️")
            print("=" * 44)
            sys.exit(0)
        else:
            print()
            print("❌ Registration failed!")
            print("   Check logs for details")
            sys.exit(1)
    else:
        # Insufficient balance
        needed = min_burn - balance_tao
        print("❌ INSUFFICIENT BALANCE!")
        print()
        print("=" * 44)
        print("  Registration Cannot Proceed")
        print("=" * 44)
        print()
        print(f"   Required: {min_burn:.4f} τ")
        print(f"   Current:  {balance_tao:.4f} τ")
        print(f"   Needed:   {needed:.4f} τ")
        print()
        print("Options:")
        print()
        print("1. Add more TAO to your wallet:")
        print(f"   Address: {wallet.coldkey.ss58_address}")
        print(f"   Amount needed: {needed:.4f} τ (+ gas)")
        print()
        print("2. Use PoW registration (free but slow):")
        print("   - Requires: pip install bittensor[torch]")
        print("   - Duration: Several hours depending on difficulty")
        print("   - Command:")
        print(f"     btcli subnet pow_register --netuid $SUBNET_ID --wallet.name $WALLET_NAME")
        print()
        print("=" * 44)
        sys.exit(2)
        
except Exception as e:
    print()
    print("=" * 44)
    print("  ❌ ERROR")
    print("=" * 44)
    print(f"  {str(e)}")
    print("=" * 44)
    sys.exit(3)
EOF

EXIT_CODE=$?
exit $EXIT_CODE
