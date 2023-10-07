resource "random_password" "synapse_db_pass" {
  length = 50
  special = false
}

resource "random_password" "synapse_authentik_client_secret" {
  length = 50
  special = false
}