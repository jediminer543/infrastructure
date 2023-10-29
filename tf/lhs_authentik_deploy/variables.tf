variable "authentik_domain" {
  type = string
  default = "authentik.domain.tld"
  description = "Baseline TLD for Authentik ingress"
}

variable "authentik_values" {
  type = string
  description = "Baseline YAML config for Authentik"
  default = <<EOF
authentik:
    error_reporting:
        enabled: true
    log_level: info
ingress:
    enabled: true
    hosts:
        - host: COMPLETED_BY_TERRAFORM
          paths:
              - path: "/"
                pathType: Prefix
postgresql:
    enabled: true
redis:
    enabled: true
livenessProbe:
    initialDelaySeconds: 120
    periodSeconds: 60
prometheus:
    serviceMonitor:
        create: true
    rules:
        create: true
EOF
}

variable "authentik_version" {
  type = string
  description = "Version of authentik to deploy"
  default = "2022.12.2"
}

variable "authentik_ingress_annotations" {
    type = string
    description = "Certmanager config for cert gen"
    default = ""
}