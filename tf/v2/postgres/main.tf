terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}


resource "kubernetes_persistent_volume_claim" "storage" {
  metadata {
    name      = var.part_of + "_psql_storage"
    namespace = var.namespace
  }
  spec {
    storage_class_name = null
    access_modes       = ["ReadWriteMany"]
    resources {
      requests = {
        "storage" = "10Gi"
      }
    }
  }
}

resource "random_password" "password" {
  length  = 50
  special = false
}

resource "kubernetes_secret" "secret" {
  metadata {
    name      = var.part_of + "_psql_secrets"
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    "PSQL_PASSWORD" = random_password.password.result
  }
}

locals {
  pod_labels = {
    "app.kubernetes.io/name"       = "postgres"
    "app.kubernetes.io/component"  = "database"
    "app.kubernetes.io/managed-by" = "opentofu"
    "app.kubernetes.io/part-of"    = var.part_of
  }
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = var.part_of + "_psql_deployment"
    namespace = var.namespace
  }
  spec {
    selector {
      match_labels = local.pod_labels
    }
    replicas = 1
    template {
      metadata {
        labels = local.pod_labels
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:11"
          env_from {
            secret_ref {
              name = kubernetes_secret.secret.metadata[0].name
            }
          }
          port {
            container_port = 5432
            name           = "postgres"
          }
          env {
            name  = "PGDATA"
            value = "/postgresql/data"
          }
          volume_mount {
            mount_path = "/postgresql/data"
            name       = "storage-pvc"
          }
        }
        volume {
          name = "storage-pvc"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.storage.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = var.part_of + "_psql_service"
    namespace = var.namespace
  }
  spec {
    port {
      name = "postgres"
      port = "5432"
    }
    selector = local.pod_labels
  }
}
