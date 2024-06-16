resource "random_password" "authentik_secret_key" {
  length = 50
  special = false
}

resource "random_password" "authentik_db_pass" {
  length = 50
  special = false
}

resource "random_password" "authentik_redis_pass" {
  length = 50
  special = false
}

resource "random_password" "authentik_postgress_pass" {
  length = 50
  special = false
}

resource "random_password" "authentik_bootstrap_pass" {
  length = 50
  special = false
}

resource "random_password" "authentik_bootstrap_token" {
  length = 50
  special = false
}