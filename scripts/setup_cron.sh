

#!/bin/bash
set -e

echo "=========================================="
echo "  Setting up Health Monitor Cron Job"
echo "=========================================="
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Check if terraform.tfvars exists
TFVARS_FILE="$PROJECT_DIR/terraform.tfvars"
if [ ! -f "$TFVARS_FILE" ]; then
    echo "ERROR: terraform.tfvars not found at $TFVARS_FILE"
    echo "Please create terraform.tfvars first."
    exit 1
fi

# Read configuration from terraform.tfvars
echo "Reading configuration from terraform.tfvars..."
SUBNET_ID=$(grep "^subnet_id" "$TFVARS_FILE" | awk '{print $3}' | tr -d '"')
WALLET_NAME=$(grep "^wallet_name" "$TFVARS_FILE" | awk '{print $3}' | tr -d '"')

if [ -z "$SUBNET_ID" ] || [ -z "$WALLET_NAME" ]; then
    echo "ERROR: Could not read subnet_id or wallet_name from terraform.tfvars"
    exit 1
fi

echo "Configuration:"
echo "  Subnet ID: $SUBNET_ID"
echo "  Wallet Name: $WALLET_NAME"
echo ""

# Create cron job command
CRON_CMD="*/5 * * * * /usr/bin/python3 $PROJECT_DIR/scripts/health_monitor.py --subnet-id $SUBNET_ID --wallet-name $WALLET_NAME --auto-restart >> /var/log/bittensor/cron-health.log 2>&1"

# Check if crontab is available
if ! command -v crontab &> /dev/null; then
    echo "⚠️  WARNING: crontab not found in this environment."
    echo ""
    echo "Cron-based health monitoring is not available."
    echo "This is normal in container/RunPod environments."
    echo ""
    echo "You can manually run health monitoring with:"
    echo "  python3 $PROJECT_DIR/scripts/health_monitor.py --subnet-id $SUBNET_ID --wallet-name $WALLET_NAME --interval 300 &"
    echo ""
    echo "Skipping cron setup..."
    exit 0
fi

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "health_monitor.py"; then
    echo "Health monitor cron job already exists."
    echo "Current cron jobs:"
    crontab -l | grep "health_monitor.py"
    echo ""
    read -p "Do you want to replace it? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi

    # Remove existing cron job
    crontab -l | grep -v "health_monitor.py" | crontab -
    echo "Removed existing cron job."
fi

# Add new cron job
(crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -

echo ""
echo " Cron job added successfully!"
echo ""
echo "Cron job details:"
echo "  Schedule: Every 5 minutes"
echo "  Command: $CRON_CMD"
echo ""
echo "Log file: /var/log/bittensor/cron-health.log"
echo ""
echo "To view current cron jobs:"
echo "  crontab -l"
echo ""
echo "To remove cron job:"
echo "  crontab -e  # then delete the health_monitor.py line"
echo ""
echo "To view logs:"
echo "  tail -f /var/log/bittensor/cron-health.log"
echo ""
