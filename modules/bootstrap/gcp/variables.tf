variable "enable" {
  type        = bool
  description = "Start or stop the Bootstrap server"
  default     = false
}

variable "prefix" {
  type        = string
  description = "Common prefix to use on resources"
  default     = "terraform"
}

variable "consul_bootstrap_token" {
  type        = string
  description = "Token to use for bootstraping the Consul cluster"
}

variable "vault_service_account" {
  type        = string
  description = "Service Account for use by Vault auto-unseal"
}

variable "server_name" {
  type        = string
  description = "Name of the bootstrap instance"
  default     = "hashicorp-bootstrap"
}

variable "server_size" {
  type        = string
  description = "Instance size of the bootstrap server"
  default     = "g1-small"
}

variable "base_image" {
  type        = string
  description = "Base image to use for bootstraping server"
  default     = "foxnet-base"
}


