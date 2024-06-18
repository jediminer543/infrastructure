variable "hedgedoc_fqdn" {
    type = string
    description = "The FQDN hedgedoc is sat on; used for oauth setup; will be passed to ingress"
}

variable "authentik_fqdn" {
    type = string
    description = "The FQDN authentik is sat on; used for oauth setup"
}