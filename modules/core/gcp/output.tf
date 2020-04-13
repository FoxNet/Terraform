output "vault_keyring" {
  value       = google_kms_key_ring.vault
  description = "Keyring to be used by Hashicorp Vault"
  sensitive   = false
}

output "vault_seal_key" {
  value       = google_kms_crypto_key.vault_seal
  description = "KMS Key for Vault's auto-unseal"
  sensitive   = false
}

output "vault_service_account" {
  value       = google_service_account.hashicorp_vault
  description = "Service account for Hashicorp Vault"
  sensitive   = false
}


