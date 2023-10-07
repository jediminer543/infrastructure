variable "kps_version" {
    type = string
    default = "36.0.2"
    description = "The version of the kube-prometheus-stack chart to deploy"
}

variable "kps_root_domain" {
    type = string
    default = "domain.tld"
    description = "The root domain under which all ingress controllers for kps should deploy"
}

variable "kps_ingress" {
    type = bool
    default = true
    description = "Enable flag for KPS ingress"
}