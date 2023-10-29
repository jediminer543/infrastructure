data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-explicit-consent"
}

data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
}

data "authentik_scope_mapping" "oauth_mappings" {
    managed_list = [
        "goauthentik.io/providers/oauth2/scope-profile",
        "goauthentik.io/providers/oauth2/scope-email",
        "goauthentik.io/providers/oauth2/scope-openid"
    ]
}

resource "authentik_provider_oauth2" "matrix_oidc" {
  name      = "matrix-synapse"
  client_id = "matrix-synapse"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  redirect_uris = [ "https://${var.synapse_fqdn}/_synapse/client/oidc/callback" ]
  client_type = "confidential"
  client_secret = random_password.synapse_authentik_client_secret.result
  property_mappings = data.authentik_scope_mapping.oauth_mappings.ids
  signing_key = data.authentik_certificate_key_pair.generated.id
}

resource "authentik_application" "matrix_synapse_authentik" {
  name              = "matrix-synapse"
  slug              = "matrix-synapse"
  protocol_provider = authentik_provider_oauth2.matrix_oidc.id
}
