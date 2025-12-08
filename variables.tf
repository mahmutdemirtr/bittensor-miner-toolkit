
variable "subnet_id" {
  description = "Bittensor subnet ID"
  type        = number
}

variable "wallet_mode" {
  description = "create or import"
  type        = string
  default     = "import"

  validation {
    condition     = contains(["create", "import"], var.wallet_mode)
    error_message = "wallet_mode must be 'create' or 'import'"
  }
}

variable "wallet_name" {
  description = "Wallet name"
  type        = string
}

variable "wallet_coldkey_mnemonic" {
  description = "Coldkey mnemonic (if importing)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "wallet_hotkey_mnemonic" {
  description = "Hotkey mnemonic (if importing)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "miner_script_url" {
  description = "URL to download miner script"
  type        = string
}

variable "enable_monitoring" {
  description = "Enable monitoring and logging"
  type        = bool
  default     = true
}
