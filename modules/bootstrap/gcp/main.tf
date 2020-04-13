locals {
  bootstrap = var.enable ? 1 : 0
}

data "google_compute_image" "base_image" {
  family = "${var.prefix}-base"
}

resource "google_compute_instance" "bootstrap" {
  count = local.bootstrap

  name         = var.server_name
  machine_type = var.server_size

  tags = ["hashicorp-server", "bootstrap"]

  boot_disk {
    initialize_params {
      image = var.base_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  shielded_instance_config {
    enable_secure_boot = true
    enable_vtpm        = true
  }

  metadata_startup_script = templatefile(
    "${path.module}/files/startup_script.sh",
  { consul_bootstrap_token = var.consul_bootstrap_token })

  service_account {
    email  = var.vault_service_account
    scopes = ["https://www.googleapis.com/auth/cloudkms"]
  }

  allow_stopping_for_update = true
}

resource "google_compute_firewall" "external_hashicorp" {
  count = local.bootstrap

  name    = "${var.prefix}-external-hashicorp-bootstrap"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "8500", "8501", "8200", "4646"]
  }

  target_tags = ["bootstrap"]
}
