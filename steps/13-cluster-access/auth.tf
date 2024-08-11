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

resource "authentik_provider_oauth2" "kube_oidc" {
  name      = "kubernetes-api"
  client_id = "kubernetes-api"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  redirect_uris = [ "http://localhost:8000", "http://localhost:18000" ]
  client_type = "public"
  property_mappings = data.authentik_scope_mapping.oauth_mappings.ids
  signing_key = data.authentik_certificate_key_pair.generated.id 
}

resource "authentik_application" "kube_authentik_app" {
  name              = "kubernetes-api"
  slug              = "kubernetes-api"
  protocol_provider = authentik_provider_oauth2.kube_oidc.id
}