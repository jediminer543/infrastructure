variable "authentik_fqdn" {
    type = string
    description = "The FQDN authentik is sat on; used for oauth setup"
}

variable "mediawiki_fqdn" {
    type = string
    default = "wiki.domain.tld"
    description = "The FQDN the wiki is to sit on; will be passed to ingress"
}
