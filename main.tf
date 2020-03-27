provider "linode" {
  token = var.linode_api_key
}

resource "linode_instance" "hashi-masters" {
    count = 1
    label = "hashi-master-${format("%2d", count.index)}"
    image = "linode/gentoo"
    region = "us-east"
    type = "g6-standard-1"
    root_pass = "terr4form-test"

    group = "hashicorp"
    tags = [ "hashi-master" ]
    swap_size = 256
    private_ip = true
}
