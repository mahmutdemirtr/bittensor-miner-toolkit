#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import subprocess
import sys
import time
import os

def log(message):
    """Print log message"""
    print(f"[SUBNET-SWITCHER] {message}")

def stop_miner():
    """Stop the running miner"""
    log("Stopping miner...")
    subprocess.run(["pkill", "-f", "neurons"], stderr=subprocess.DEVNULL)
    subprocess.run(["pkill", "-f", "miner"], stderr=subprocess.DEVNULL)
    time.sleep(3)

    # Remove PID file
    if os.path.exists("/var/run/bittensor-miner.pid"):
        os.remove("/var/run/bittensor-miner.pid")

    log("✅ Miner stopped")

def setup_subnet(subnet_id):
    """Setup/install subnet miner if needed"""
    log(f"Checking subnet {subnet_id} installation...")

    script_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    setup_script = os.path.join(script_dir, "scripts", "subnet_manager.sh")

    if not os.path.exists(setup_script):
        log(f"WARNING: subnet_manager.sh not found at {setup_script}")
        return False

    log(f"Running subnet {subnet_id} setup...")
    result = subprocess.run([
        "bash",
        setup_script,
        str(subnet_id)
    ])

    if result.returncode == 0:
        log(f"✅ Subnet {subnet_id} setup completed")
        return True
    else:
        log(f"ERROR: Subnet {subnet_id} setup failed")
        return False

def start_miner(subnet_id, wallet_name):
    """Start miner on new subnet"""
    log(f"Starting miner on subnet {subnet_id}...")

    script_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    start_script = os.path.join(script_dir, "scripts", "start_miner.sh")

    result = subprocess.run([
        "bash",
        start_script,
        str(subnet_id),
        wallet_name
    ])

    if result.returncode == 0:
        log(f"✅ Miner started on subnet {subnet_id}")
        return True
    else:
        log(f"❌ Failed to start miner")
        return False

def update_terraform_config(subnet_id):
    """Update terraform.tfvars with new subnet ID"""
    script_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    tfvars_file = os.path.join(script_dir, "terraform.tfvars")

    if not os.path.exists(tfvars_file):
        log(f"⚠️  WARNING: terraform.tfvars not found at {tfvars_file}")
        return False

    log(f"Updating terraform.tfvars with subnet_id = {subnet_id}")

    # Read current config
    with open(tfvars_file, "r") as f:
        lines = f.readlines()

    # Update subnet_id line
    updated = False
    for i, line in enumerate(lines):
        if line.strip().startswith("subnet_id"):
            lines[i] = f"subnet_id = {subnet_id}\n"
            updated = True
            break

    if not updated:
        log("⚠️  WARNING: subnet_id not found in terraform.tfvars")
        return False

    # Write updated config
    with open(tfvars_file, "w") as f:
        f.writelines(lines)

    log("✅ terraform.tfvars updated")
    return True

def get_wallet_name():
    """Read wallet name from terraform.tfvars"""
    script_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    tfvars_file = os.path.join(script_dir, "terraform.tfvars")

    if not os.path.exists(tfvars_file):
        return None

    with open(tfvars_file, "r") as f:
        for line in f:
            if line.strip().startswith("wallet_name"):
                # Extract wallet name from: wallet_name = "value"
                parts = line.split("=")
                if len(parts) == 2:
                    wallet_name = parts[1].strip().strip('"')
                    return wallet_name

    return None

def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Usage: subnet_switcher.py <new_subnet_id> [wallet_name]")
        print("Example: subnet_switcher.py 1")
        print("         subnet_switcher.py 18 mahmut_wallet")
        sys.exit(1)

    new_subnet_id = int(sys.argv[1])

    # Get wallet name from args or terraform.tfvars
    if len(sys.argv) >= 3:
        wallet_name = sys.argv[2]
        log(f"Using wallet name from argument: {wallet_name}")
    else:
        wallet_name = get_wallet_name()
        if wallet_name:
            log(f"Using wallet name from terraform.tfvars: {wallet_name}")
        else:
            log("ERROR: Could not determine wallet name. Please provide it as argument.")
            sys.exit(1)

    log("=" * 60)
    log(f"Switching to subnet {new_subnet_id}")
    log(f"Wallet: {wallet_name}")
    log("=" * 60)

    # Step 1: Stop current miner
    stop_miner()

    # Step 2: Setup subnet (install if needed)
    if not setup_subnet(new_subnet_id):
        log("=" * 60)
        log("❌ ERROR: Subnet setup failed")
        log("=" * 60)
        sys.exit(1)

    # Step 3: Update terraform config
    update_terraform_config(new_subnet_id)

    # Step 4: Start miner on new subnet
    if start_miner(new_subnet_id, wallet_name):
        log("=" * 60)
        log(f"✅ SUCCESS: Successfully switched to subnet {new_subnet_id}")
        log("=" * 60)
    else:
        log("=" * 60)
        log("❌ ERROR: Failed to switch subnet")
        log("=" * 60)
        sys.exit(1)

if __name__ == "__main__":
    main()
