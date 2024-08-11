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

resource "random_password" "kube_client_secret" {
  length = 50
  special = false
}

resource "authentik_provider_oauth2" "kube_oidc" {
  name      = "kubernetes-api"
  client_id = "kubernetes-api"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  redirect_uris = [ "https://${var.synapse_fqdn}/_synapse/client/oidc/callback" ]
  client_type = "confidential"
  client_secret = random_password.kube_client_secret.result
  property_mappings = data.authentik_scope_mapping.oauth_mappings.ids
  signing_key = data.authentik_certificate_key_pair.generated.id
}

resource "authentik_application" "kube_authentik_app" {
  name              = "kubernetes-api"
  slug              = "kubernetes-api"
  protocol_provider = authentik_provider_oauth2.kube_oidc.id
}