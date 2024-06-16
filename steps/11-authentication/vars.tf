variable "kubectl_config" {
  type = string
  default = "~/.kube/config"
}

variable "authentik_version" {
  type = string
  description = "Version of authentik to deploy"
  default = "2022.12.2"
}