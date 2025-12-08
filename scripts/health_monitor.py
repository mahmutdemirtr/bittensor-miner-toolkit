#!/usr/bin/env python3
import subprocess
import time
import os
from datetime import datetime

LOG_FILE = "/var/log/bittensor/health.log"
MINER_PID_FILE = "/var/run/bittensor-miner.pid"
MINER_LOG_FILE = "/var/log/bittensor/miner.log"

def log(message):
    """Log message to file and console"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_msg = f"[{timestamp}] {message}"

    # Ensure log directory exists
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)

    # Log to file
    with open(LOG_FILE, "a") as f:
        f.write(log_msg + "\n")

    # Print to console
    print(log_msg)

def is_miner_running():
    """Check if miner process is running"""
    if not os.path.exists(MINER_PID_FILE):
        return False

    try:
        with open(MINER_PID_FILE, "r") as f:
            pid = int(f.read().strip())

        # Check if process exists
        os.kill(pid, 0)
        return True
    except (OSError, ValueError):
        # Process doesn't exist or invalid PID
        return False

def get_miner_pid():
    """Get miner process PID"""
    if not os.path.exists(MINER_PID_FILE):
        return None

    try:
        with open(MINER_PID_FILE, "r") as f:
            return int(f.read().strip())
    except (OSError, ValueError):
        return None

def check_gpu_status():
    """Check GPU availability and temperature"""
    try:
        result = subprocess.run(
            ["nvidia-smi", "--query-gpu=temperature.gpu,utilization.gpu,memory.used",
             "--format=csv,noheader,nounits"],
            capture_output=True,
            text=True,
            check=True
        )

        temp, util, mem = result.stdout.strip().split(", ")
        temp = int(temp)
        util = int(util)
        mem = int(mem)

        # Check for issues
        issues = []
        if temp > 85:
            issues.append(f"High temperature: {temp}°C")
        if util < 5:
            issues.append(f"Low GPU utilization: {util}%")

        return {
            "status": "ok" if not issues else "warning",
            "temperature": temp,
            "utilization": util,
            "memory_used": mem,
            "issues": issues
        }
    except (subprocess.CalledProcessError, FileNotFoundError, ValueError):
        return {
            "status": "error",
            "issues": ["nvidia-smi not available"]
        }

def check_log_errors():
    """Check miner log for recent errors"""
    if not os.path.exists(MINER_LOG_FILE):
        return []

    try:
        # Get last 50 lines of log
        result = subprocess.run(
            ["tail", "-n", "50", MINER_LOG_FILE],
            capture_output=True,
            text=True
        )

        errors = []
        for line in result.stdout.split("\n"):
            if any(keyword in line.lower() for keyword in ["error", "exception", "failed", "critical"]):
                errors.append(line.strip())

        return errors[-5:]  # Return last 5 errors
    except Exception as e:
        return [f"Error reading log: {str(e)}"]

def restart_miner(subnet_id, wallet_name):
    """Restart the miner"""
    log(f"Attempting to restart miner (subnet: {subnet_id}, wallet: {wallet_name})")

    script_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    start_script = os.path.join(script_dir, "scripts", "start_miner.sh")

    if not os.path.exists(start_script):
        log(f"ERROR: start_miner.sh not found at {start_script}")
        return False

    try:
        subprocess.run(
            [start_script, str(subnet_id), wallet_name],
            check=True
        )
        log("Miner restart initiated successfully")
        return True
    except subprocess.CalledProcessError as e:
        log(f"ERROR: Failed to restart miner: {e}")
        return False

def run_health_check(subnet_id=None, wallet_name=None, auto_restart=False):
    """Run complete health check"""
    log("=" * 60)
    log("Starting health check")
    log("=" * 60)

    # Check miner status
    miner_running = is_miner_running()
    pid = get_miner_pid()

    if miner_running:
        log(f"✓ Miner is RUNNING (PID: {pid})")
    else:
        log("✗ Miner is NOT RUNNING")

        if auto_restart and subnet_id and wallet_name:
            log("Auto-restart is enabled, attempting restart...")
            if restart_miner(subnet_id, wallet_name):
                time.sleep(5)  # Wait for miner to start
                if is_miner_running():
                    log("✓ Miner restarted successfully")
                else:
                    log("✗ Miner restart failed")
        else:
            log("Auto-restart disabled or missing parameters")

    # Check GPU status
    log("\n--- GPU Status ---")
    gpu_status = check_gpu_status()

    if gpu_status["status"] == "ok":
        log(f"✓ GPU Status: OK")
        log(f"  Temperature: {gpu_status['temperature']}°C")
        log(f"  Utilization: {gpu_status['utilization']}%")
        log(f"  Memory Used: {gpu_status['memory_used']}MB")
    elif gpu_status["status"] == "warning":
        log(f"⚠ GPU Status: WARNING")
        for issue in gpu_status["issues"]:
            log(f"  - {issue}")
    else:
        log(f"✗ GPU Status: ERROR")
        for issue in gpu_status["issues"]:
            log(f"  - {issue}")

    # Check recent errors
    log("\n--- Recent Log Errors ---")
    errors = check_log_errors()

    if errors:
        log(f"⚠ Found {len(errors)} recent errors:")
        for error in errors:
            log(f"  {error}")
    else:
        log("✓ No recent errors found")

    log("\n" + "=" * 60)
    log("Health check completed")
    log("=" * 60)

def main():
    """Main function"""
    import argparse

    parser = argparse.ArgumentParser(description="Bittensor Miner Health Monitor")
    parser.add_argument("--subnet-id", type=int, help="Subnet ID for auto-restart")
    parser.add_argument("--wallet-name", type=str, help="Wallet name for auto-restart")
    parser.add_argument("--auto-restart", action="store_true", help="Auto-restart miner if stopped")
    parser.add_argument("--interval", type=int, default=0, help="Check interval in seconds (0 = run once)")

    args = parser.parse_args()

    # Run health check
    if args.interval > 0:
        log(f"Starting continuous monitoring (interval: {args.interval}s)")
        try:
            while True:
                run_health_check(args.subnet_id, args.wallet_name, args.auto_restart)
                time.sleep(args.interval)
        except KeyboardInterrupt:
            log("\nMonitoring stopped by user")
    else:
        run_health_check(args.subnet_id, args.wallet_name, args.auto_restart)

if __name__ == "__main__":
    main()
