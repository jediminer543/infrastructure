variable "namespace" {
  type = string
  description = "kubernetes namespace to put authentik in"
  default = "authentik"
}

variable "authentik_domain" {
  type = string
  default = "authentik.domain.tld"
  description = "Baseline TLD for Authentik ingress"
}

variable "authentik_values" {
  type = string
  description = "Baseline YAML config for Authentik"
  // TODO replace please
  default = <<EOF
EOF
}

variable "authentik_version" {
  type = string
  description = "Version of authentik to deploy"
  default = "2024.4.2"
}

variable "authentik_ingress_annotations" {
    type = string
    description = "Certmanager config for cert gen"
    default = ""
}