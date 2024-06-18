resource "helm_release" "postgres" {
  name       = "hedgedoc-postgres"
  namespace  = kubernetes_namespace.ns.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "11.6.7"
  create_namespace = false



  set {
    name = "metrics.enabled"
    value = true
  }

  set {
    name = "auth.username"
    value = local.database_username
  }

  set {
    name = "auth.password"
    value = random_password.hedgedoc_db_pass.result
  }

  set {
    name = "containerPorts.postgresql"
    value = local.database_port
  }

  set {
    name = "auth.database"
    value = local.database_database
  }
}
