output "authentik_fqdn" {
    value = module.lhs_authentik.authentik_fqdn
    description = "The FQDN that Authentik is deployed on"    
}

output "authentik_key" {
    value = module.lhs_authentik.authentik_key
    description = "The API Key usable to setup Authentik"
    sensitive = true
}

output "authentik_cluster_name" {
    value = module.lhs_authentik.authentik_cluster_name
    description = "In cluster dns of authentik"
}

output "manifest" {
    value = module.lhs_authentik.manifest
}