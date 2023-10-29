data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-explicit-consent"
}

data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
}

data "authentik_property_mapping_saml" "saml_mappings" {
    managed_list = [
        "goauthentik.io/providers/saml/upn",
        "goauthentik.io/providers/saml/name",
        "goauthentik.io/providers/saml/email",
        "goauthentik.io/providers/saml/username",
        "goauthentik.io/providers/saml/uid",
        "goauthentik.io/providers/saml/groups",
        "goauthentik.io/providers/saml/ms-windowsaccountname",
    ]
}

resource "authentik_provider_saml" "mediawiki_saml" {
  name      = "mediawiki"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  // FIX ME INSECURE
  acs_url = "http://${var.mediawiki_fqdn}/simplesaml/module.php/saml/sp/saml2-acs.php/default-sp"
  issuer = "https://${var.mediawiki_fqdn}/simplesaml/module.php/saml/sp/saml2-acs.php/default-sp"
  sp_binding = "post"
  signing_kp = data.authentik_certificate_key_pair.generated.id
  property_mappings = data.authentik_property_mapping_saml.saml_mappings.ids
}

resource "authentik_application" "mediawiki_authentik" {
  name              = "mediawiki"
  slug              = "mediawiki"
  protocol_provider = authentik_provider_saml.mediawiki_saml.id
}
