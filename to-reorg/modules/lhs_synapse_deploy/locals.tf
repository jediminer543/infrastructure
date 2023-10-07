locals {
    database_username = "synapse"
    database_database = "synapse"
    database_host = "${helm_release.matrix_postgres.id}-postgresql"
    database_port = "5432"
    oidc_issuer = "https://${var.authentik_fqdn}/application/o/${authentik_application.matrix_synapse_authentik.slug}/"
    /*
    #oidc_issuer = "https://${var.authentik_fqdn}"
    #authorization_endpoint: ${local.oidc_authorization_endpoint}
    #token_endpoint: ${local.oidc_token_endpoint}
    #userinfo_endpoint: ${local.oidc_userinfo_endpoint}
    #jwks_uri: ${local.oidc_jwks_uri}
    oidc_authorization_endpoint = "https://${var.authentik_fqdn}/application/o/authorize/"
    oidc_token_endpoint = "https://${var.authentik_fqdn}/application/o/token/"
    oidc_userinfo_endpoint = "https://${var.authentik_fqdn}/application/o/userinfo/"
    oidc_jwks_uri = "https://${var.authentik_fqdn}/application/o/${authentik_application.matrix_synapse_authentik.slug}/jwks/"
    */
    database_config = <<EOF
database:
  name: psycopg2
  txn_limit: 10000
  allow_unsafe_locale: true
  args:
    user: ${local.database_username}
    password: ${random_password.synapse_db_pass.result}
    database: ${local.database_database}
    host: ${local.database_host}
    port: ${local.database_port}
    cp_min: 5
    cp_max: 10
    keepalives_idle: 10
    keepalives_interval: 10
    keepalives_count: 3
EOF
    openid_config = <<EOF
oidc_providers:
  - idp_id: authentik
    idp_name: authentik
    discover: true
    issuer: ${local.oidc_issuer} # "https://your.authentik.example.org/application/o/your-app-slug/" # TO BE FILLED: domain and slug
    client_id: ${authentik_provider_oauth2.matrix_oidc.client_id} # TO BE FILLED
    client_secret: ${authentik_provider_oauth2.matrix_oidc.client_secret} # TO BE FILLED
    scopes:
      - "openid"
      - "profile"
      - "email"
    user_mapping_provider:
      config:
        localpart_template: "{{ user.preferred_username }}"
        display_name_template: "{{ user.preferred_username|capitalize }}" # TO BE FILLED: If your users have names in Authentik and you want those in Synapse, this should be replaced with user.name|capitalize.
EOF
    server_misc_config = <<EOF
server_name: ${var.synapse_fqdn}
public_baseurl: https://${var.synapse_fqdn}
web_client_location: https://${var.element_fqdn}
media_store_path: "/media_store"
signing_key_path: "/keys/${var.synapse_fqdn}.signing.key"
log_config: "/config/${var.synapse_fqdn}.log.config"
EOF
    appservice_config = {
      app_service_config_files = [

      ]
    }
    synapse_config = yamlencode(merge(
        yamldecode(var.synapse_config_base), 
        yamldecode(local.server_misc_config), 
        yamldecode(local.database_config),
        yamldecode(local.openid_config),
        local.appservice_config
        ))
}
