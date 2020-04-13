provider "vault" {}

provider "consul" {}

provider "google" {
  credentials = file(var.gcp_credentials)
  project     = var.gcp_project_id
  version     = "~> 3.0.0"
}

provider "random" {
  version = "~> 2.2.0"
}

module "core-gcp" {
  source = "./modules/core/gcp"
  prefix = var.prefix
}

module "bootstrap-gcp" {
  source = "./modules/bootstrap/gcp"

  enable                 = true # Need to make this automatic
  prefix                 = var.prefix
  consul_bootstrap_token = var.consul_bootstrap_token
  vault_service_account  = module.core-gcp.vault_service_account.email
}

module "hashicorp-common" {
  source                = "./modules/hashicorp"
  domain                = var.domain
  datacenter            = var.datacenter
  pki_root_ou           = var.organizational_unit
  pki_root_organization = var.organization
}
