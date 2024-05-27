resource "kubernetes_service" "authentik_postgresql_hl" {
  metadata {
    annotations = {
      "service.alpha.kubernetes.io/tolerate-unready-endpoints" = "true"
    }
    labels = {
      "app.kubernetes.io/component"  = "primary"
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "postgresql"
      "app.kubernetes.io/version"    = "15.4.0"
      "helm.sh/chart"                = "postgresql-12.12.10"
    }
    name      = "postgresql-hl"
    namespace = "NAMESPACE_HERE"
  }
  spec {
    type                        = "ClusterIP"
    publish_not_ready_addresses = true
    selector = {
      "app.kubernetes.io/component" = "primary"
      "app.kubernetes.io/instance"  = "lhs-authentik"
      "app.kubernetes.io/name"      = "postgresql"
    }
    port {
      name        = "tcp-postgresql"
      port        = 5432
      target_port = "tcp-postgresql"
    }
  }
}

resource "kubernetes_service" "authentik_postgresql" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "primary"
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "postgresql"
      "app.kubernetes.io/version"    = "15.4.0"
      "helm.sh/chart"                = "postgresql-12.12.10"
    }
    name      = "postgresql"
    namespace = "NAMESPACE_HERE"
  }
  spec {
    type             = "ClusterIP"
    session_affinity = "None"
    port {
      name        = "tcp-postgresql"
      port        = 5432
      target_port = "tcp-postgresql"
    }
    selector = {
      "app.kubernetes.io/component" = "primary"
      "app.kubernetes.io/instance"  = "lhs-authentik"
      "app.kubernetes.io/name"      = "postgresql"
    }

  }
}

resource "kubernetes_secret" "authentik_postgresql" {
  metadata {
    labels = {
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "postgresql"
        "app.kubernetes.io/version"    = "15.4.0"
        "helm.sh/chart"                = "postgresql-12.12.10"
    }
    name = "authentik-postgresql"
    namespace = "NAMESPACE_HERE"
  }
  type = "Opaque"
  data = {
    "password" = ""
    "postgres-password" = ""
  }
}

resource "kubernetes_config_map" "authentik_postgresql_extended_configuration" {
  metadata {
    labels = {
        "app.kubernetes.io/component"  = "primary"
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "postgresql"
        "app.kubernetes.io/version"    = "15.4.0"
        "helm.sh/chart"                = "postgresql-12.12.10"
    }
    name = "authentik-postgresql-extended-configuration"
    namespace = "NAMESPACE_HERE"
  }
  data = {
    "override.conf" = "max_connections = 500"
  }
}

resource "kubernetes_stateful_set" "authentik_postgresql" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "primary"
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "postgresql"
      "app.kubernetes.io/version"    = "15.4.0"
      "helm.sh/chart"                = "postgresql-12.12.10"
    }
    name = "authentik-postgresql"
    namespace = "NAMESPACE_HERE"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
          "app.kubernetes.io/component" = "primary"
          "app.kubernetes.io/instance"  = "lhs-authentik"
          "app.kubernetes.io/name"      = "postgresql"
      }
    }
    service_name = "postgresql-hl"
    template {
      metadata {
          labels = {
            "app.kubernetes.io/component"  = "primary"
            "app.kubernetes.io/instance"   = "lhs-authentik"
            "app.kubernetes.io/managed-by" = "Helm"
            "app.kubernetes.io/name"       = "postgresql"
            "app.kubernetes.io/version"    = "15.4.0"
            "helm.sh/chart"                = "postgresql-12.12.10"
          }
          name = "postgresql"
      }
      spec {
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              pod_affinity_term {
                label_selector {
                  match_labels = {
                    "app.kubernetes.io/component" = "primary"
                    "app.kubernetes.io/instance"  = "lhs-authentik"
                    "app.kubernetes.io/name"      = "postgresql"
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
              weight = 1
            }
          }
        }
        container {
          name = "postgresql"
          image           = "docker.io/bitnami/postgresql:15.4.0-debian-11-r45"
          image_pull_policy = "IfNotPresent"
          env {
            name  = "BITNAMI_DEBUG"
            value = "false"
          }
          env {
            name  = "POSTGRESQL_PORT_NUMBER"
            value = "5432"
          }
          env {
            name  = "POSTGRESQL_VOLUME_DIR"
            value = "/bitnami/postgresql"
          }
          env {
            name  = "PGDATA"
            value = "/bitnami/postgresql/data"
          }
          env {
            name  = "POSTGRES_USER"
            value = "authentik"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "password"
                name = "lhs-authentik-postgresql"
              }
            }
          }
          env {
            name = "POSTGRES_POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "postgres-password"
                name = "lhs-authentik-postgresql"
              }
            }
          }
          env {
            name  = "POSTGRES_DATABASE"
            value = "authentik"
          }
          env {
            name  = "POSTGRESQL_ENABLE_LDAP"
            value = "no"
          }
          env {
            name  = "POSTGRESQL_ENABLE_TLS"
            value = "no"
          }
          env {
            name  = "POSTGRESQL_LOG_HOSTNAME"
            value = "false"
          }
          env {
            name  = "POSTGRESQL_LOG_CONNECTIONS"
            value = "false"
          }
          env {
            name  = "POSTGRESQL_LOG_DISCONNECTIONS"
            value = "false"
          }
          env {
            name  = "POSTGRESQL_PGAUDIT_LOG_CATALOG"
            value = "off"
          }
          env {
            name  = "POSTGRESQL_CLIENT_MIN_MESSAGES"
            value = "error"
          }
          env {
            name  = "POSTGRESQL_SHARED_PRELOAD_LIBRARIES"
            value = "pgaudit"
          }
          liveness_probe {
            exec {
              command = [
                "/bin/sh",
                "-c",
                "exec pg_isready -U \"authentik\" -d \"dbname=authentik\" -h 127.0.0.1 -p 5432",
              ]
            }
            failure_threshold    = 6
            initial_delay_seconds = 30
            period_seconds       = 10
            success_threshold    = 1
            timeout_seconds      = 5
          }
          readiness_probe {
            exec {
              command = [
                "/bin/sh",
                "-c",
                "-e",
                <<-EOT
                exec pg_isready -U "authentik" -d "dbname=authentik" -h 127.0.0.1 -p 5432
                [ -f /opt/bitnami/postgresql/tmp/.initialized ] || [ -f /bitnami/postgresql/.initialized ]

                EOT
                ,
              ]
            }
            failure_threshold     = 6
            initial_delay_seconds = 5
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 5
          }
          port {
            container_port = 5432
            name          = "tcp-postgresql"
          }
          resources {
            requests = {
                "cpu"    = "250m"
                "memory" = "256Mi"
            }
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = [
                "ALL",
              ]
            }
            run_as_group   = 0
            run_as_non_root = true
            run_as_user    = 1001
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
          volume_mount {
            mount_path = "/bitnami/postgresql/conf/conf.d/"
            name      = "postgresql-extended-config"
          }
          volume_mount {
            mount_path = "/dev/shm"
            name      = "dshm"
          }
          volume_mount {
            mount_path = "/bitnami/postgresql"
            name      = "data"
          }
        }
        host_ipc = false
        host_network = false
        security_context {
          fs_group = "1001"
        }
        service_account_name = "default"
        volume {
          config_map {
            name = "lhs-authentik-postgresql-extended-configuration"
          }
          name = "postgresql-extended-config"
        }
        volume {
          empty_dir {
            medium = "Memory"
          }
          name = "dshm"
        }
      }
    }
    update_strategy {
      rolling_update {
        
      }
      type = "RollingUpdate"
    }
    volume_claim_template {
      metadata {
        annotations = {
          "helm.sh/resource-policy" = "keep"
        }
        name = "data"
      }
      spec {
        access_modes = [
          "ReadWriteOnce",
        ]
        resources {
          requests = {
            "storage" = "8Gi"
          }
        }
      }
    }
  }
}