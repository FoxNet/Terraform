/*****
 * Enable APIs
 */
resource "google_project_service" "primary_cloudresourcemanager" {
  service = "cloudresourcemanager.googleapis.com"
}
resource "google_project_service" "primary_serviceusage" {
  service = "serviceusage.googleapis.com"
}
resource "google_project_service" "primary_cloudkms" {
  service = "cloudkms.googleapis.com"
}


/*****
 * Hashicorp Base
 */

data "google_iam_policy" "vault_kms" {
  binding {
    role    = "roles/owner"
    members = ["serviceAccount:${google_service_account.hashicorp_vault.email}"]
  }
}

resource "google_service_account" "hashicorp_vault" {
  account_id   = "hashicorp-vault"
  display_name = "Hashicorp Vault"
  description  = "Allow Hashicorp Vault access to various Google Services"
}

resource "google_kms_key_ring" "vault" {
  name       = "vault-keyring"
  location   = "global"
  depends_on = [google_project_service.primary_cloudkms]

  lifecycle {
    prevent_destroy = true
  }
}
resource "google_kms_key_ring_iam_policy" "vault_keyring" {
  key_ring_id = google_kms_key_ring.vault.id
  policy_data = data.google_iam_policy.vault_kms.policy_data
}
resource "google_kms_crypto_key" "vault_seal" {
  name     = "vault-seal"
  key_ring = google_kms_key_ring.vault.id

  lifecycle {
    prevent_destroy = true
  }
}
