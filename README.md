# Bittensor Miner Quick Start Guide

Automated setup with Terraform - Subnet 1 (Apex) mining in 5 simple steps!

---

## Step 1: Clone the Project

```bash
cd /workspace
git clone https://github.com/mahmutdemirtr/bittensor-miner-toolkit.git
cd bittensor-miner-toolkit
```

---

## Step 2: Install Terraform

```bash
cd /tmp
wget https://releases.hashicorp.com/terraform/1.14.1/terraform_1.14.1_linux_amd64.zip
unzip terraform_1.14.1_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version
```

**Expected output:** `Terraform v1.14.1`

---

## Step 3: Configure Wallet Settings

```bash
cd /workspace/bittensor-miner-toolkit

# Create terraform.tfvars file
cp terraform.tfvars.example terraform.tfvars

# Edit the file
nano terraform.tfvars
```

**ONLY FILL THESE LINES:**
```hcl
wallet_name = "my_wallet"                    # Your wallet name
wallet_coldkey_mnemonic = "word1 word2..."   # Coldkey 12 words
wallet_hotkey_mnemonic = "word1 word2..."    # Hotkey 12 words
```

**Other settings are automatic!** Subnet 1 is set as default.
**Security:** NEVER share your terraform.tfvars file!

---

## Step 4: Run Terraform (Automated Setup)

```bash
cd /workspace/bittensor-miner-toolkit

# Initialize Terraform
terraform init

# Check the installation plan
terraform plan

# Run automated setup
terraform apply -auto-approve
```

**This command automatically:**
1. Installs Bittensor framework
2. Imports wallet
3. Sets up Subnet 1 (Apex)
4. Installs and configures Apex CLI

---

## Step 5: Start Mining with Apex CLI

**Subnet 1 special case:** No traditional miner - competition-based system!

```bash
# Configure PATH
export PATH="/root/.local/bin:$PATH"

# Open dashboard (interactive UI)
cd /workspace/prompting
apex dashboard

# List competitions
apex competitions

# Submit algorithm
apex submit
```

**How It Works:**
- Write Python algorithms for competitions
- Submit via Apex CLI
- Validators evaluate performance
- Best algorithms earn TAO

**Example Competition:**
- Matrix Compression v1 (Active)
- Solo type competition
- Python package: matrix_compression

---

## After Pod Restart

If pod restarts, just recreate symlinks:

```bash
cd /workspace/bittensor-miner-toolkit
./scripts/pod_restart_recovery.sh
```

**Or manually:**
```bash
ln -sf /workspace/bittensor-miner-toolkit ~/bittensor-miner-toolkit
ln -sf /workspace/.bittensor ~/.bittensor
ln -sf /workspace/bittensor-venv ~/bittensor-venv
ln -sf /workspace/prompting ~/prompting

export PATH="/root/.local/bin:$PATH"
```

---

## Important Notes

### Subnet 1 (Apex) Features
- Competition-based mining
- Traditional miner.py DOES NOT WORK
- Uses Apex CLI
- Wallet must be registered on subnet (UID: 1)

### Earning TAO
- Submit algorithms to competitions
- Track results via dashboard
- Best performance = Highest TAO rewards

### Other Subnets
To use another subnet, edit terraform.tfvars:
```bash
nano terraform.tfvars
# subnet_id = 1    # Old value (Apex)
# subnet_id = 18   # New value (example: Cortex.t)

terraform apply -auto-approve    # Apply changes
```

**NOTE:** Other subnets require high registration fees!
- Subnet 18: 500,000 TAO burn cost
- Subnet 21: 10,000,000 TAO burn cost

### Profitability Analysis
```bash
# Find most profitable subnet
./scripts/profitability_scanner.py --subnets 1,18,21
```

---

## Useful Commands

```bash
# Apex dashboard
apex dashboard

# List competitions
apex competitions

# Check wallet balance
source /workspace/bittensor-venv/bin/activate
python -m bittensor wallet balance --wallet.name your_wallet_name

# Subnet status
python -m bittensor wallet overview --wallet.name your_wallet_name

# Switch subnet
./scripts/subnet_switcher.py <subnet_id>
```

---

## Help and Documentation

- **Apex Docs:** https://docs.macrocosmos.ai/subnets/new-subnet-1-apex
- **GitHub:** https://github.com/macrocosm-os/prompting
- **Bittensor:** https://docs.bittensor.com

---

## Troubleshooting

### Terraform Errors

#### "Missing false expression in conditional" (main.tf)
**Cause:** Heredoc strings in ternary operators need to be wrapped

**Solution:**
```bash
# Already fixed in main.tf - if you see this error, pull latest code
git pull origin main
# Or manually wrap heredocs with chomp():
# value = var.subnet_id == 1 ? chomp(<<-EOT ... EOT) : chomp(<<-EOT ... EOT)
```

#### "crontab: command not found" (setup_cron.sh)
**Cause:** Crontab not available in container environment

**Solution:**
```bash
# Already fixed in scripts/setup_cron.sh - script handles missing crontab gracefully
# To run health monitor manually:
python3 /workspace/bittensor-miner-toolkit/scripts/health_monitor.py \
  --subnet-id 1 \
  --wallet-name your_wallet_name \
  --interval 300 &
```

#### General terraform errors
```bash
# Start over
terraform destroy
terraform init
terraform apply -auto-approve
```

### Apex CLI Errors

#### "apex: command not found"
```bash
export PATH="/root/.local/bin:$PATH"
echo 'export PATH="/root/.local/bin:$PATH"' >> ~/.bashrc
```

#### "No .apex.config.json file"
```bash
cd /workspace/prompting
cat > .apex.config.json << EOF
{
  "hotkey_file_path": "/workspace/.bittensor/wallets/your_wallet/hotkeys/default",
  "timeout": 60.0
}
EOF
```

### Wallet Errors

#### Wallet not registered
```bash
source /workspace/bittensor-venv/bin/activate
python -m bittensor subnet register --netuid 1 --wallet.name your_wallet_name
```

#### "FileExistsError: ~/.bittensor"
```bash
# Remove and recreate as symlink
rm -f ~/.bittensor
mkdir -p /workspace/.bittensor/wallets
ln -sf /workspace/.bittensor ~/.bittensor
```

---

**Good luck! Open an issue for questions.**
