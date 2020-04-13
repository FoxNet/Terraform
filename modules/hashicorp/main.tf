resource "consul_acl_policy" "admin" {
  name        = "admin"
  description = "Admin Rules"
  rules       = <<-RULE
    acl = "write"
    agent_prefix "" {
        policy = "write"
    }
    key_prefix "" {
        policy = "write"
    }
    node_prefix "" {
        policy = "write"
    }
    operator = "write"
    query_prefix "" {
        policy = "write"
    }
    service_prefix "" {
        policy = "write"
        intentions = "write"
    }
    RULE
}

resource "consul_acl_policy" "dns" {
  name        = "dns"
  description = "DNS Read Access"
  rules       = <<-RULE
    node_prefix "" {
      policy = "read"
    }
    service_prefix "" {
      policy = "read"
    }
    RULE
}

resource "consul_acl_policy" "replication" {
  name        = "replication"
  description = "Consul ACL Replication Policy"
  rules       = <<-RULE
    acl = "write"

    operator = "write"

    service_prefix "" {
      policy = "read"
      intentions = "read"
    }
    RULE
}

resource "vault_mount" "pki_ca" {
  path                      = "pki_ca"
  type                      = "pki"
  default_lease_ttl_seconds = tostring(tonumber(var.pki_root_ttl) / 4)
  max_lease_ttl_seconds     = tostring(tonumber(var.pki_root_ttl) / 2)
}
resource "vault_mount" "pki" {
  path                      = "pki"
  type                      = "pki"
  default_lease_ttl_seconds = 3600    #One Hour
  max_lease_ttl_seconds     = 2592000 #One Month
}

resource "vault_pki_secret_backend_config_urls" "config_urls" {
  for_each = tomap({ pki = vault_mount.pki, pki_ca = vault_mount.pki_ca })

  backend              = each.value.path
  issuing_certificates = ["https://vault.${var.datacenter}.${var.domain}:8200/v1/${each.value.path}/ca"]
}

resource "vault_pki_secret_backend_root_cert" "pki_ca" {
  backend = vault_mount.pki_ca.path

  type                 = "internal"
  common_name          = var.domain
  ttl                  = var.pki_root_ttl
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = var.pki_root_ou
  organization         = var.pki_root_organization
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  backend = vault_mount.pki.path

  type        = "internal"
  common_name = "${var.datacenter}.${var.domain}"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "pki" {
  backend = vault_mount.pki_ca.path

  csr                   = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name           = "${var.datacenter}.${var.domain}"
  ou                    = var.datacenter
  organization          = var.pki_root_organization
  permitted_dns_domains = [".${var.datacenter}.${var.domain}"]
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend = vault_mount.pki.path

  certificate = vault_pki_secret_backend_root_sign_intermediate.pki.certificate
}

resource "vault_pki_secret_backend_role" "servers" {
  backend = vault_mount.pki.path

  name            = "server"
  ttl             = "86400"
  max_ttl         = "604800"
  allow_localhost = true
  allowed_domains = [
    "*.node.${var.datacenter}.${var.domain}",
    "server.${var.datacenter}.${var.domain}"
  ]
  allow_glob_domains = true
  allow_bare_domains = true
  allow_subdomains   = false
  allow_ip_sans      = true
  server_flag        = true
  client_flag        = true
  key_usage = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment",
  ]
}

resource "vault_pki_secret_backend_role" "clients" {
  backend = vault_mount.pki.path

  name            = "client"
  ttl             = "86400"
  max_ttl         = "604800"
  allow_localhost = true
  allowed_domains = [
    "*.node.${var.datacenter}.${var.domain}",
    "client.${var.datacenter}.${var.domain}"
  ]
  allow_glob_domains = true
  allow_bare_domains = false
  allow_subdomains   = false
  allow_ip_sans      = true
  server_flag        = true
  client_flag        = true
  key_usage = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment",
  ]
}
