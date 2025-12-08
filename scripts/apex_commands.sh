#!/bin/bash

# Apex CLI Quick Commands Helper
# Usage: ./scripts/apex_commands.sh [command]

export PATH="/root/.local/bin:$PATH"
cd /workspace/prompting

COMMAND=${1:-help}

case $COMMAND in
    dashboard|dash)
        echo "Opening Apex Dashboard..."
        apex dashboard
        ;;

    competitions|comp)
        echo "Listing competitions..."
        apex competitions
        ;;

    submit)
        echo "Submitting to competition..."
        apex submit
        ;;

    status)
        echo "============================================"
        echo "  Apex Status"
        echo "============================================"
        echo ""

        # Version
        APEX_VERSION=$(apex version 2>&1 | grep -oP 'v\d+\.\d+\.\d+' || echo "unknown")
        echo "Apex CLI: $APEX_VERSION"

        # Config
        if [ -f ".apex.config.json" ]; then
            echo "Config: Found (.apex.config.json)"
        else
            echo "Config: Missing!"
        fi

        # Wallet
        WALLET_PATH=$(cat .apex.config.json 2>/dev/null | grep -oP 'wallets/\K[^/]+' || echo "unknown")
        echo "Wallet: $WALLET_PATH"

        echo ""
        echo "Active Competitions:"
        apex competitions 2>/dev/null
        echo ""
        ;;

    link)
        echo "Linking wallet..."
        apex link
        ;;

    version|ver)
        apex version
        ;;

    help|*)
        cat << 'EOF'
============================================
  Apex CLI Quick Commands
============================================

Usage: ./scripts/apex_commands.sh [command]

Commands:
  dashboard, dash     Open interactive dashboard
  competitions, comp  List active competitions
  submit             Submit algorithm to competition
  status             Show Apex status and config
  link               Link wallet to Apex
  version, ver       Show Apex CLI version
  help               Show this help message

Examples:
  ./scripts/apex_commands.sh dashboard
  ./scripts/apex_commands.sh comp
  ./scripts/apex_commands.sh status

Or use Apex CLI directly:
  export PATH="/root/.local/bin:$PATH"
  cd /workspace/prompting
  apex dashboard

Documentation:
  https://docs.macrocosmos.ai/subnets/new-subnet-1-apex

============================================
EOF
        ;;
esac
