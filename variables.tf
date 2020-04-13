variable "prefix" {
  type        = string
  description = "Common prefix to use on resources"
  default     = "terraform"
}

variable "consul_bootstrap_token" {
  type        = string
  description = "Token to use for bootstraping the Consul cluster"
}

variable "domain" {
  type = string
}
variable "datacenter" {
  type = string
}
variable "organization" {
  type = string
}
variable "organizational_unit" {
  type = string
}

variable "gcp_credentials" {
  type        = string
  description = "A credential file granting access to GCP"
}
variable "gcp_project_id" {
  type        = string
  description = "The ID of the primary GCP project"
}
variable "gcp_region" {
  type        = list(string)
  description = "The Google Cloud Regions to deploy into"
}
variable "gcp_zones" {
  type        = map(list(string))
  description = "A list of zones to use per region"
  #Default is all zones in all regions
  default = {
    asia-east1              = ["a", "b", "c"]
    asia-east2              = ["a", "b", "c"]
    asia-northeast1         = ["a", "b", "c"]
    asia-northeast2         = ["a", "b", "c"]
    asia-northeast3         = ["a", "b", "c"]
    asia-south1             = ["a", "b", "c"]
    asia-southeast1         = ["a", "b", "c"]
    australia-southeast1    = ["a", "b", "c"]
    europe-north1           = ["a", "b", "c"]
    europe-west1            = ["b", "c", "d"]
    europe-west2            = ["a", "b", "c"]
    europe-west3            = ["a", "b", "c"]
    europe-west4            = ["a", "b", "c"]
    europe-west6            = ["a", "b", "c"]
    northamerica-northeast1 = ["a", "b", "c"]
    southamerica-east1      = ["a", "b", "c"]
    us-central1             = ["a", "b", "c", "f"]
    us-east1                = ["b", "c", "d"]
    us-east4                = ["a", "b", "c"]
    us-west1                = ["a", "b", "c"]
    us-west2                = ["a", "b", "c"]
    us-west3                = ["a", "b", "c"]
  }
}

variable "gcp_project_name" {
  type        = string
  default     = ""
  description = "The name of the GCP project"
}
variable "gcp_base_image" {
  type    = string
  default = ""
}
variable "gcp_startup_script_location" {
  type    = string
  default = "US"
}
