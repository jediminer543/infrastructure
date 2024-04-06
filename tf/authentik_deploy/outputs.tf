output "authentik_fqdn" {
    value = var.authentik_domain
    description = "The FQDN that Authentik is deployed on"    
}

output "authentik_key" {
    value = random_password.authentik_bootstrap_token.result
    description = "The API Key usable to setup Authentik"
    sensitive = true
}

output "authentik_cluster_name" {
    value = "${helm_release.authentik.name}.${helm_release.authentik.namespace}"
}