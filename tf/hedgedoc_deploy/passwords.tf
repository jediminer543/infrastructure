resource "random_password" "hedgedoc_authentik_client_secret" {
  length = 50
  special = false
}

resource "random_password" "hedgedoc_db_pass" {
  length = 50
  special = false
}