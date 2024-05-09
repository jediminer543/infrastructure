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
    value = "${data.helm_template.authentik.name}.${data.helm_template.authentik.namespace}"
}

output "manifest" {
    value = data.helm_template.authentik.manifest
}