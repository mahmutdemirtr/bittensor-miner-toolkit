#!/bin/bash

# Pod Restart Recovery Script
# Automatically recreates symlinks and restores environment after RunPod restart

set -e

echo "============================================"
echo "  RunPod Restart Recovery"
echo "============================================"
echo ""

# 1. Create symlinks
echo "1. Creating symlinks..."
ln -sf /workspace/bittensor-miner-toolkit ~/bittensor-miner-toolkit
ln -sf /workspace/.bittensor ~/.bittensor
ln -sf /workspace/bittensor-venv ~/bittensor-venv
ln -sf /workspace/prompting ~/prompting 2>/dev/null || echo "   (prompting directory not found - skip)"
echo "   ✅ Symlinks created"
echo ""

# 2. Create log directory
echo "2. Creating log directory..."
sudo mkdir -p /var/log/bittensor
sudo chmod 755 /var/log/bittensor
echo "   ✅ Log directory ready"
echo ""

# 3. Configure PATH for Apex CLI
echo "3. Configuring Apex CLI PATH..."
export PATH="/root/.local/bin:$PATH"
if ! grep -q '/root/.local/bin' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="/root/.local/bin:$PATH"' >> ~/.bashrc
fi
echo "   ✅ PATH configured"
echo ""

# 4. Verify installations
echo "4. Verifying installations..."

# Check Terraform
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform version -json 2>/dev/null | grep -oP '"terraform_version":"\K[^"]+' || terraform version 2>&1 | head -1)
    echo "   ✅ Terraform: $TERRAFORM_VERSION"
else
    echo "   ⚠️  Terraform not found - reinstalling..."
    cd /tmp
    wget -q https://releases.hashicorp.com/terraform/1.14.1/terraform_1.14.1_linux_amd64.zip
    unzip -q terraform_1.14.1_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    echo "   ✅ Terraform v1.14.1 installed"
fi

# Check Bittensor
if [ -f ~/bittensor-venv/bin/python ]; then
    echo "   ✅ Bittensor venv: Found"
else
    echo "   ❌ Bittensor venv: Not found"
fi

# Check Wallet
if [ -d ~/.bittensor/wallets ]; then
    WALLET_COUNT=$(ls -1 ~/.bittensor/wallets 2>/dev/null | wc -l)
    echo "   ✅ Wallets: $WALLET_COUNT found"
else
    echo "   ❌ Wallets: Not found"
fi

# Check Apex CLI
if command -v apex &> /dev/null; then
    APEX_VERSION=$(apex version 2>&1 | grep -oP 'v\d+\.\d+\.\d+' || echo "unknown")
    echo "   ✅ Apex CLI: $APEX_VERSION"
else
    echo "   ⚠️  Apex CLI: Not found (run terraform apply if using Subnet 1)"
fi

echo ""
echo "============================================"
echo "  Recovery Complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  cd ~/bittensor-miner-toolkit"
echo "  terraform init  # If needed"
echo "  ./scripts/status.sh  # Check miner status"
echo ""
echo "For Subnet 1 (Apex):"
echo "  export PATH=\"/root/.local/bin:\$PATH\""
echo "  apex --help"
echo ""
