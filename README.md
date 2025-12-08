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

### Profitability Analysis & Auto-Switch
```bash
# Find most profitable subnet
python3 ./scripts/profitability_scanner.py --subnets 1,18,21

# Auto-switch to most profitable subnet
python3 ./scripts/profitability_scanner.py --subnets 1,3,8,18,21 --auto-switch
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

## Notes

### Supported Subnets with Automated Terraform Setup

This toolkit provides **full automated setup** for the following subnets:

| Subnet ID | Name | Type | Setup Script | Mining Method |
|-----------|------|------|--------------|---------------|
| **1** | Text Prompting (Apex) | Competition-based | `subnet_1_setup.sh` | Apex CLI (apex submit) |
| **3** | Data Vending | Traditional Miner | `subnet_3_setup.sh` | neurons/miner.py |
| **8** | Taoshi | Financial Prediction | `subnet_8_setup.sh` | neurons/miner.py |
| **18** | Cortex.t | LLM | `subnet_18_setup.sh` | neurons/miner.py |
| **21** | FileTAO | Storage | `subnet_21_setup.sh` | neurons/miner.py |

---

**Good luck! Open an issue for questions.**
