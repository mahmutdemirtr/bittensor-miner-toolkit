#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import requests
import json
import sys
import os
from datetime import datetime

LOG_FILE = "/var/log/bittensor/profitability.log"

def log(message):
    """Log message to file and console"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_msg = f"[{timestamp}] {message}"

    # Ensure log directory exists
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)

    with open(LOG_FILE, "a") as f:
        f.write(log_msg + "\n")

    print(log_msg)

def get_subnet_stats(subnet_id):
    """
    Get stats for a specific subnet

    TODO: Replace with actual Bittensor API endpoint
    For now, returns mock data
    """
    # Mock data for testing
    # In production, this would call actual Bittensor API
    # Example: https://api.taostats.io/api/subnet/{subnet_id}

    mock_data = {
        1: {
            "subnet_id": 1,
            "name": "Text Prompting",
            "emission": 12500000,
            "neurons": 1024,
            "difficulty": 45.2,
            "tempo": 360,
            "min_stake": 1000
        },
        18: {
            "subnet_id": 18,
            "name": "Cortex.t",
            "emission": 8500000,
            "neurons": 512,
            "difficulty": 32.8,
            "tempo": 360,
            "min_stake": 500
        },
        21: {
            "subnet_id": 21,
            "name": "FileTAO",
            "emission": 6200000,
            "neurons": 256,
            "difficulty": 28.5,
            "tempo": 360,
            "min_stake": 750
        }
    }

    if subnet_id in mock_data:
        return mock_data[subnet_id]
    else:
        # Return generic data for unknown subnets
        return {
            "subnet_id": subnet_id,
            "name": f"Subnet {subnet_id}",
            "emission": 5000000,
            "neurons": 128,
            "difficulty": 25.0,
            "tempo": 360,
            "min_stake": 1000
        }

def calculate_profitability(subnet_stats):
    """
    Calculate profitability score for a subnet

    Formula: emission / (neurons * difficulty * min_stake)
    Higher score = more profitable
    """
    try:
        emission = subnet_stats.get("emission", 0)
        neurons = subnet_stats.get("neurons", 1)
        difficulty = subnet_stats.get("difficulty", 1)
        min_stake = subnet_stats.get("min_stake", 1)

        # Calculate profitability score
        score = emission / (neurons * difficulty * min_stake)

        return score
    except Exception as e:
        log(f"ERROR: Failed to calculate profitability: {e}")
        return 0

def scan_subnets(subnet_list):
    """Scan multiple subnets and return profitability ranking"""
    results = []

    log("=" * 60)
    log("Starting Profitability Scan")
    log("=" * 60)

    for subnet_id in subnet_list:
        log(f"\nScanning subnet {subnet_id}...")

        stats = get_subnet_stats(subnet_id)
        score = calculate_profitability(stats)

        results.append({
            "subnet_id": subnet_id,
            "name": stats.get("name", "Unknown"),
            "emission": stats.get("emission", 0),
            "neurons": stats.get("neurons", 0),
            "difficulty": stats.get("difficulty", 0),
            "min_stake": stats.get("min_stake", 0),
            "score": score
        })

        log(f"  Name: {stats.get('name', 'Unknown')}")
        log(f"  Emission: {stats.get('emission', 0):,}")
        log(f"  Neurons: {stats.get('neurons', 0)}")
        log(f"  Difficulty: {stats.get('difficulty', 0)}")
        log(f"  Min Stake: {stats.get('min_stake', 0)}")
        log(f"  Profitability Score: {score:.6f}")

    # Sort by profitability score (descending)
    results.sort(key=lambda x: x["score"], reverse=True)

    return results

def display_results(results):
    """Display scan results in a formatted table"""
    log("\n" + "=" * 60)
    log("Profitability Ranking")
    log("=" * 60)

    print("\n{:<6} {:<20} {:<15} {:<12}".format("Rank", "Subnet", "Name", "Score"))
    print("-" * 60)

    for i, result in enumerate(results, 1):
        print("{:<6} {:<20} {:<15} {:<12.6f}".format(
            i,
            f"Subnet {result['subnet_id']}",
            result['name'][:15],
            result['score']
        ))

    log("\n" + "=" * 60)
    log(f"Most Profitable: Subnet {results[0]['subnet_id']} ({results[0]['name']})")
    log(f"Profitability Score: {results[0]['score']:.6f}")
    log("=" * 60)

    return results[0]['subnet_id']

def get_terraform_subnets():
    """Read subnet list from terraform.tfvars or use defaults"""
    script_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    tfvars_file = os.path.join(script_dir, "terraform.tfvars")

    # Default subnet list
    default_subnets = [1, 18, 21]

    if not os.path.exists(tfvars_file):
        log(f"INFO: terraform.tfvars not found, using default subnets: {default_subnets}")
        return default_subnets

    return default_subnets

def main():
    """Main function"""
    import argparse

    parser = argparse.ArgumentParser(description="Bittensor Subnet Profitability Scanner")
    parser.add_argument("--subnets", type=str, help="Comma-separated list of subnet IDs (e.g., 1,18,21)")
    parser.add_argument("--auto-switch", action="store_true", help="Automatically switch to most profitable subnet")

    args = parser.parse_args()

    # Get subnet list
    if args.subnets:
        subnet_list = [int(x.strip()) for x in args.subnets.split(",")]
    else:
        subnet_list = get_terraform_subnets()

    log(f"Scanning subnets: {subnet_list}")

    # Scan subnets
    results = scan_subnets(subnet_list)

    # Display results
    most_profitable = display_results(results)

    # Auto-switch if requested
    if args.auto_switch:
        log(f"\nAuto-switch enabled. Switching to subnet {most_profitable}...")

        script_dir = os.path.dirname(os.path.abspath(__file__))
        switcher_script = os.path.join(script_dir, "subnet_switcher.py")

        if os.path.exists(switcher_script):
            import subprocess
            result = subprocess.run([
                "python3",
                switcher_script,
                str(most_profitable)
            ])

            if result.returncode == 0:
                log(f"SUCCESS: Switched to subnet {most_profitable}")
            else:
                log(f"ERROR: Failed to switch to subnet {most_profitable}")
        else:
            log(f"ERROR: subnet_switcher.py not found at {switcher_script}")

    log("\nScan completed.")

if __name__ == "__main__":
    main()
