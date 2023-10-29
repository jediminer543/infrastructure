terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
  }
}

resource "kubernetes_namespace" "registry_ns" {
  metadata {
    name = "lhs-registry"
  }
}

resource "kubernetes_persistent_volume_claim" "registry_pvc" {
  metadata {
    name = "registry-pvc"
    namespace = kubernetes_namespace.registry_ns.metadata[0].name
  }
  spec {
    access_modes = [ "ReadWriteOnce" ]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "registry" {
  metadata {
    name = "lhs-registry"
    namespace = kubernetes_namespace.registry_ns.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "registry"
      }
    }
    template {
      metadata {
        labels = {
          app = "registry"
        }
      }
      spec {
        container {
          name = "registry"
          image = "registry:2.8.1"
          port {
            container_port = 5000
          }
          volume_mount {
            name = "repo-vol"
            mount_path = "/var/lib/registry"
          }
          /*
          volume_mount {
            name = "certs-vol"
            mount_path = "/certs"
            read_only = true
          }
          volume_mount {
            name = "auth-vol"
            mount_path = "/auth"
            read_only = true
          }
          */
        }
        volume {
          name = "repo-vol"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.registry_pvc.metadata[0].name
          }
        }
        /*
        volume {
          name = "certs-vol"
          secret {
            secret_name = "certs-secret"
          }
        }
        volume {
          name = "auth-vol"
          secret {
            secret_name = "auth-secret"
          }
        }
        */
      }
    }
  }
}

resource "kubernetes_service" "registry_svc" {
  metadata {
    name = "lhs-registry"
    namespace = kubernetes_namespace.registry_ns.metadata[0].name
  }
  spec {
    selector = {
        app = "registry"
    }
    port {
      port = 5000
    }
  }
}