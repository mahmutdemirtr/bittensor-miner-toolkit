terraform {
  required_version = ">= 1.0"
}

# Bittensor installation
resource "null_resource" "install_bittensor" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/install_bittensor.sh"
  }

  triggers = {
    always_run = timestamp()
  }
}

# Wallet setup
resource "null_resource" "setup_wallet" {
  depends_on = [null_resource.install_bittensor]

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/setup_wallet.sh ${var.wallet_mode} ${var.wallet_name}"
    environment = {
      COLDKEY_MNEMONIC = var.wallet_coldkey_mnemonic
      HOTKEY_MNEMONIC  = var.wallet_hotkey_mnemonic
    }
  }

  triggers = {
    wallet_mode = var.wallet_mode
    wallet_name = var.wallet_name
  }
}

# Subnet-specific setup
resource "null_resource" "setup_subnet" {
  depends_on = [null_resource.setup_wallet]

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/subnet_manager.sh ${var.subnet_id} ${var.wallet_name}"
  }

  triggers = {
    subnet_id   = var.subnet_id
    wallet_name = var.wallet_name
  }
}

# Check and auto-register to subnet
resource "null_resource" "check_and_register" {
  depends_on = [null_resource.setup_subnet]

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/check_and_register.sh ${var.subnet_id} ${var.wallet_name}"
  }

  triggers = {
    subnet_id   = var.subnet_id
    wallet_name = var.wallet_name
  }
}

# Start miner (Note: Subnet 1 uses Apex CLI, not traditional miner)
resource "null_resource" "start_miner" {
  depends_on = [null_resource.check_and_register]

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/start_miner.sh ${var.subnet_id} ${var.wallet_name}"
  }

  triggers = {
    subnet_id   = var.subnet_id
    wallet_name = var.wallet_name
  }
}

# Cron setup for automated monitoring (replaces setup_health_monitor)
resource "null_resource" "setup_cron" {
  depends_on = [null_resource.start_miner]

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/setup_cron.sh"
  }

  triggers = {
    always_run = timestamp()
  }
}

# Output important information
output "wallet_name" {
  value       = var.wallet_name
  description = "Name of the configured wallet"
}

output "subnet_id" {
  value       = var.subnet_id
  description = "Configured subnet ID"
}

output "log_location" {
  value       = "/var/log/bittensor/${var.wallet_name}.log"
  description = "Location of miner logs"
}

output "next_steps" {
  value = var.subnet_id == 1 ? chomp(<<-EOT

    ============================================
    Subnet 1 (Apex) Setup Complete!
    ============================================

    Apex CLI is ready! Use these commands:

    Quick Commands:
      ./scripts/apex_dashboard.sh          # Open interactive dashboard
      ./scripts/apex_commands.sh status    # Check status
      ./scripts/apex_commands.sh comp      # List competitions
      ./scripts/apex_commands.sh submit    # Submit algorithm

    Or use Apex CLI directly:
      export PATH="/root/.local/bin:$PATH"
      cd /workspace/prompting
      apex dashboard

    Documentation:
      https://docs.macrocosmos.ai/subnets/new-subnet-1-apex

    ============================================
  EOT
  ) : chomp(<<-EOT

    ============================================
    Miner Setup Complete!
    ============================================

    Check miner status:
      ./scripts/status.sh

    View logs:
      tail -f /var/log/bittensor/miner.log

    Switch subnet:
      ./scripts/subnet_switcher.py <subnet_id>

    ============================================
  EOT
  )
  description = "Next steps after Terraform apply"
}
