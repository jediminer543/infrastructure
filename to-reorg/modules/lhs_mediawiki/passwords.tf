resource "random_password" "mediawiki_db_pass" {
  length = 50
  special = false
}

resource "random_password" "mediawiki_secret_key" {
  length = 64
  lower = false
  upper = false
  numeric = false
  special = true
  override_special = "123456789ABCDEF"
}

resource "random_password" "mediawiki_upgrade_key" {
  length = 16
  lower = false
  upper = false
  numeric = false
  special = true
  override_special = "123456789ABCDEF"
}

resource "random_password" "mediawiki_god_pass" {
  length = 50
  special = false
}

resource "random_password" "synapse_authentik_client_secret" {
  length = 50
  special = false
}