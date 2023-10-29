locals {
    database_username = "mediawiki"
    database_database = "mediawiki"
    database_port = 5432
    database_host = "${helm_release.mediawiki_postgres.id}-postgresql"
    god_name = "superadmin"
}