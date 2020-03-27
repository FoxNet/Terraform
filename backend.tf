terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "foxnet"

    workspaces {
      name = "dev-linode-us-east"
    }
  }
}
