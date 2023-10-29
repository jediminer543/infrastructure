variable "authentik_fqdn" {
    type = string
    description = "The FQDN authentik is sat on; used for oauth setup"
}

variable "synapse_config_base" {
  type = string
  description = "The base config for synapse; see https://matrix-org.github.io/synapse/latest/usage/configuration/homeserver_sample_config.html"
}

variable "synapse_config_logging" {
  type = string
  description = "The logging config for synapse; see https://matrix-org.github.io/synapse/latest/usage/configuration/logging_sample_config.html"
}

variable "synapse_fqdn" {
    type = string
    default = "matrix.domain.tld"
    description = "The FQDN synapse is to sit on; will be passed to ingress"
}

variable "synapse_cert_stuff" {
  type = object({
    enable = bool
    secret = string
  })
  description = "A trick to bypass cert issues"
  default = {
    enable = true
    secret = "cacert"
  }
}

variable "synapse_ver" {
  type = string
  description = "Version of the synapse image to deploy"
  default = "latest"
}

variable "element_ver" {
  type = string
  description = "Version of the element image to deploy"
  default = "latest"
}

variable "element_config_base" {
  type = string
  description = "The base config for element; see https://github.com/vector-im/element-web/blob/develop/docs/config.md"
}

variable "element_fqdn" {
    type = string
    default = "element.domain.tld"
    description = "The FQDN element is to sit on; will be passed to ingress"
}