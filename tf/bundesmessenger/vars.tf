variable "bundesmessenger_ver" {
  type = string
  description = "Version of the bundesmessenger image to deploy"
  default = "latest"
}

variable "bundesmessenger_config_base" {
  type = string
  description = "The base config for bundesmessenger; see Who the fuck knows where the docs are"
}

variable "bundesmessenger_fqdn" {
    type = string
    default = "bundesmessenger.domain.tld"
    description = "The FQDN bundesmessenger is to sit on; will be passed to ingress"
}

variable "synapse_fqdn" {
    type = string
    default = "matrix.domain.tld"
    description = "The FQDN synapse is to sit on; default homeserver for bundesmesenger"
}