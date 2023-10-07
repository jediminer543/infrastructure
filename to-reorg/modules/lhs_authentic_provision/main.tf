terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "2022.6.3"
    }
  }
}

/*
data "authentik_flow" "default-authentication-flow" {
  slug = "default-authentication-flow"
}

resource "authentik_provider_ldap" "name" {
  name      = "ldap-app"
  base_dn   = "dc=ldap,dc=goauthentik,dc=io"
  bind_flow = data.authentik_flow.default-authentication-flow.id
}

resource "authentik_application" "name" {
  name              = "ldap-app"
  slug              = "ldap-app"
  protocol_provider = authentik_provider_ldap.name.id
}

resource "authentik_user" "example_admin" {
  username = "example_admin"
  name     = "example_admin"
}

resource "authentik_group" "example_admins" {
  name = "example_admins"
  users = [ authentik_user.example_admin.id ]
  is_superuser = true
}

resource "authentik_token" "example_admin_password" {
  identifier = "example_admin_pass"
  intent = "app_password"
  user = authentik_user.example_admin.id
  retrieve_key = true
}
*/