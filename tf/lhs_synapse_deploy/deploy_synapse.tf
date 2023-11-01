resource "kubernetes_persistent_volume_claim" "synapse_media_pvc" {
  metadata {
    name = "media-pvc"
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
  wait_until_bound = false
}

resource "kubernetes_persistent_volume_claim" "synapse_data_pvc" {
  metadata {
    name = "data-pvc"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
  }
  spec {
    access_modes = [ "ReadWriteOnce" ]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_persistent_volume_claim" "synapse_keys_pvc" {
  metadata {
    name = "key-pvc"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
  }
  spec {
    access_modes = [ "ReadWriteOnce" ]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_config_map" "synapse_config" {
  metadata {
    name = "synapse-config"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
    labels = {
      "config_hash_synapse" = substr(sha256(local.synapse_config), 0, 63)
      "config_hash_synapse_log" = substr(sha256(var.synapse_config_logging), 0, 63)
    }
  }
  data = {
    "homeserver.yaml" = local.synapse_config
    "${var.synapse_fqdn}.log.config" = var.synapse_config_logging
  }
}

# resource "kubernetes_job_v1" "synapse_generate" {
#   metadata {
#     name = "lhs-synapse-generate"
#     namespace = kubernetes_namespace.matrix_ns.metadata[0].name
#   }
#   spec {
#     selector {
#     }
#     template {
#       metadata { 
#         labels = {
#           job = "synapse-generate"
#         }
#       }
#       spec {
#         container {
#           name = "synapse-generate"
#           image = "matrixdotorg/synapse:${var.synapse_ver}"
#           args = ["generate"]
#           env {
#             name = "SYNAPSE_SERVER_NAME"
#             value = var.synapse_fqdn
#           }
#           env {
#             name = "SYNAPSE_REPORT_STATS"
#             value = "yes"
#           }
#           env {
#             name = "SYNAPSE_CONFIG_PATH"
#             value = "/keys/homeserver.yaml"
#           }
#           volume_mount {
#             name = "key-vol"
#             mount_path = "/data"
#           }
#           volume_mount {
#             name = "data-vol"
#             mount_path = "/keys"
#           }
#         }
#         volume {
#           name = "key-vol"
#           persistent_volume_claim {
#             claim_name = kubernetes_persistent_volume_claim.synapse_keys_pvc.metadata[0].name
#           }
#         }
#         volume {
#           name = "data-vol"
#           empty_dir {
            
#           }
#         }
#       }
#     }
#   }
#   timeouts {
#     create = "120s"
#     update = "120s"
#   }
# }

resource "kubernetes_deployment" "synapse" {
  depends_on = [
    helm_release.matrix_postgres,
    kubernetes_job_v1.synapse_generate,
    kubernetes_config_map.synapse_config,
  ]
  metadata {
    name = "lhs-synapse"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "synapse"
        //config_hash_synapse = substr(sha256(local.synapse_config), 0, 63)
        //config_hash_synapse_log = substr(sha256(var.synapse_config_logging), 0, 63)
      }
    }
    template {
      metadata {
        labels = {
          app = "synapse"
          config_hash_synapse = substr(sha256(local.synapse_config), 0, 63)
          config_hash_synapse_log = substr(sha256(var.synapse_config_logging), 0, 63)
        }
      }
      spec {
        init_container {
           name = "synapse-generate"
          image = "matrixdotorg/synapse:${var.synapse_ver}"
          args = ["generate"]
          env {
            name = "SYNAPSE_SERVER_NAME"
            value = var.synapse_fqdn
          }
          env {
            name = "SYNAPSE_REPORT_STATS"
            value = "yes"
          }
          env {
            name = "SYNAPSE_CONFIG_PATH"
            value = "/keys/homeserver.yaml"
          }
          volume_mount {
            name = "key-vol"
            mount_path = "/data"
          }
          volume_mount {
            name = "data-vol"
            mount_path = "/keys"
          }
        }
        container {
          name = "synapse"
          image = "matrixdotorg/synapse:${var.synapse_ver}"
          port {
            container_port = 8008
          }
          env {
            name = "SYNAPSE_CONFIG_PATH"
            value = "/config/homeserver.yaml"
          }
          /*
          env {
            name = "SYNAPSE_SERVER_NAME"
            value = var.synapse_fqdn
          }
          env {
            name = "SYNAPSE_REPORT_STATS"
            value = "yes"
          }
          */
          volume_mount {
            name = "data-vol"
            mount_path = "/data"
          }
          volume_mount {
            name = "media-vol"
            mount_path = "/media_store"
          }
          volume_mount {
            name = "key-vol"
            mount_path = "/keys"
          }
          volume_mount {
            name = "config-vol"
            mount_path = "/config"
            read_only = true
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 8008
            }
            initial_delay_seconds = 30
            period_seconds = 10
          }
          dynamic env {
            for_each = var.synapse_cert_stuff.enable == true ? [1] : []
            content {
              name = "SSL_CERT_FILE"
              value = "/certhack/minica.pem"
            }
          }
          dynamic volume_mount {
            for_each = var.synapse_cert_stuff.enable == true ? [1] : []
            content {
              name = "cert-vol"
              mount_path = "/certhack"
              read_only = true
            }
          }
        }
        dynamic volume {
          for_each = var.synapse_cert_stuff.enable == true ? [1] : []
          content {
            name = "cert-vol"
            secret {
              secret_name = var.synapse_cert_stuff.secret
            }
          }
        }
        volume {
          name = "data-vol"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.synapse_data_pvc.metadata[0].name
          }
        }
        volume {
          name = "media-vol"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.synapse_media_pvc.metadata[0].name
          }
        }
        volume {
          name = "key-vol"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.synapse_keys_pvc.metadata[0].name
          }
        }
        volume {
          name = "config-vol"
          config_map {
            name = kubernetes_config_map.synapse_config.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "synapse_svc" {
  depends_on = [
    kubernetes_deployment.synapse
  ]
  metadata {
    name = "lhs-synapse"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
  }
  spec {
    selector = {
        app = "synapse"
    }
    port {
      name = "synapse"
      port = 8008
    }
  }
}

resource "kubernetes_ingress_v1" "synapse_ingress" {
  metadata {
    name = "lhs-synapse"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" = "lets-encrypt-http"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "70m"
    }
  }
  spec {
    // ingress_class_name = "public"
    rule {
      host = var.synapse_fqdn
      http {
        path {
          backend {
            service {
              name = kubernetes_service.synapse_svc.metadata[0].name
              port {
                name = "synapse"
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "lhs-synape-web-cert"
      hosts = [
        var.synapse_fqdn
      ]
    }
  }
}