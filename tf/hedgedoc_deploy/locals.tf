locals {
    database_username = "hedgedoc"
    database_database = "hedgedoc"
    database_port = "5432"
    database_host = "${helm_release.postgres.id}-postgresql"
    database_url = "postgres://${local.database_username}:${random_password.hedgedoc_db_pass.result}@${local.database_host}:${local.database_port}/hedgedoc"
}