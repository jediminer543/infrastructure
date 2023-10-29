resource "kubernetes_persistent_volume_claim" "mediawiki_images_pvc" {
  metadata {
    name = "images-pvc"
    namespace = kubernetes_namespace.mediawiki_ns.metadata[0].name
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

resource "kubernetes_deployment" "mediawiki" {
  depends_on = [
    helm_release.mediawiki_postgres,
  ]
  metadata {
    name = "lhs-mediawiki"
    namespace = kubernetes_namespace.mediawiki_ns.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mediawiki"
      }
    }
    template {
      metadata {
        labels = {
          app = "mediawiki"
        }
      }
      spec {
        container {
          name = "mediawiki"
          image = "ghcr.io/leedshackspace/docker-mediawiki:latest"
          port {
            container_port = 80
          }
          env {
            name = "WG_SITENAME"
            value = "Leeds Hackspace"
          }
          env {
            name = "WG_SERVER"
            value = "https://${var.mediawiki_fqdn}"
          }
          env {
            name = "WG_SECRETKEY"
            value = random_password.mediawiki_secret_key.result
          }
          env {
            name = "WG_UPGRADEKEY"
            value = random_password.mediawiki_upgrade_key.result
          }
          env {
            name = "DB_HOST"
            value = local.database_host
          }
          env {
            name = "DB_NAME"
            value = local.database_database
          }
          env {
            name = "DB_USER"
            value = local.database_username
          }
          env {
            name = "DB_PASS"
            value = random_password.mediawiki_db_pass.result
          }
          /*
          env {
            name = "GOD_NAME"
            value = local.god_name
          }
          env {
            name = "GOD_PASS"
            value = random_password.mediawiki_god_pass.result
          }
          */
          env {
            name = "SAML_METADATA_URL"
            value = "https://${var.authentik_fqdn}/api/v3/providers/saml/${authentik_provider_saml.mediawiki_saml.id}/metadata/?download"
          }
          env {
            name = "SSL_BYPASS"
            value = true
          }
          volume_mount {
            name = "images-vol"
            mount_path = "/images"
          }
          /*
          liveness_probe {
            http_get {
              path = "/api.php?action=query&meta=siteinfo&format=none"
              port = 80
            }
            initial_delay_seconds = 60
            period_seconds = 60
          }
          */
        }
        volume {
          name = "images-vol"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mediawiki_images_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mediawiki_svc" {
  depends_on = [
    kubernetes_deployment.mediawiki
  ]
  metadata {
    name = "lhs-mediawiki"
    namespace = kubernetes_namespace.mediawiki_ns.metadata[0].name
  }
  spec {
    selector = {
        app = "mediawiki"
    }
    port {
      name = "mediawiki"
      port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "synapse_ingress" {
  metadata {
    name = "lhs-mediawiki"
    namespace = kubernetes_namespace.mediawiki_ns.metadata[0].name
  }
  spec {
    rule {
      host = var.mediawiki_fqdn
      http {
        path {
          backend {
            service {
              name = kubernetes_service.mediawiki_svc.metadata[0].name
              port {
                name = "mediawiki"
              }
            }
          }
        }
      }
    }
    tls {
      
    }
  }
}