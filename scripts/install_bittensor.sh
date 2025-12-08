#!/bin/bash
set -e

echo "=== Bittensor Installation Started ==="

# NVIDIA driver check
echo "Checking NVIDIA drivers..."
if ! command -v nvidia-smi &> /dev/null; then
    echo "ERROR: NVIDIA drivers not found!"
    exit 1
fi
nvidia-smi

# Python installation
echo "Installing Python 3.10+..."
apt update || true  # Ignore apt update errors
apt install -y python3 python3-pip python3-venv

# Check Python version
python3 --version

# Create virtual environment
echo "Creating virtual environment..."
cd ~
python3 -m venv bittensor-venv
source bittensor-venv/bin/activate

# Install Bittensor
echo "Installing Bittensor..."
pip install --upgrade pip --no-cache-dir
pip install bittensor --no-cache-dir --timeout=1000

# Verify installation
echo "Verifying Bittensor installation..."
~/bittensor-venv/bin/python -m bittensor --help | head -15

echo ""
echo "=== Bittensor Installation Complete ==="
echo "Virtual environment location: ~/bittensor-venv"
