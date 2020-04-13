variable "domain" {
  type = string
}
variable "datacenter" {
  type = string
}
variable "pki_root_ttl" {
  type    = string
  default = "315360000"
}
variable "pki_root_ou" {
  type = string
}
variable "pki_root_organization" {
  type = string
}
