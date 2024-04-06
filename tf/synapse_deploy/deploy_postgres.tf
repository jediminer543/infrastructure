/*
resource "kubernetes_persistent_volume_claim" "database_pvc" {
  metadata {
    name = "database-pvc"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
  }
  spec {
    access_modes = [ "ReadWriteOnce" ]
    resources {
      requests = {
        storage = "4Gi"
      }
    }
  }
}
*/

resource "helm_release" "matrix_postgres" {
  name       = "lhs-matrix-postgres"
  namespace  = kubernetes_namespace.matrix_ns.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "11.6.7"



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
    value = random_password.synapse_db_pass.result
  }

  set {
    name = "containerPorts.postgresql"
    value = local.database_port
  }

  set {
    name = "auth.database"
    value = local.database_database
  }
  // SET FECKING TYPES https://github.com/bitnami/bitnami-docker-postgresql/issues/127
  /*
  ********************************************************
  Error during initialisation:
      Database is incorrectly configured:

      - 'COLLATE' is set to 'en_US.UTF-8'. Should be 'C'
      - 'CTYPE' is set to 'en_US.UTF-8'. Should be 'C'

  See docs/postgres.md for more information.
  There may be more information in the logs.
  ********************************************************
  */
  set {
    name = "primary.extraEnvVars"
    value = yamlencode([
    {
      name = "LC_CTYPE"
      value = "C"
    },
    {
      name = "LC_COLLATE"
      value = "C"
    },
    {
      name = "LC_ALL"
      value = "C"
    }
    ])
  }
}
