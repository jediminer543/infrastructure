//gitlab.opencode.de/bwi/bundesmessenger/backend/container-images/bundesmessenger-web:2.10.0-jammy-production

locals {
    bundesmessenger_config_overrides = <<EOF
{
    "default_server_config": {
        "m.homeserver": {
            "base_url": "https://${var.synapse_fqdn}"
        }
    }
}
EOF
    bundesmessenger_config = jsonencode(merge(
        jsondecode(var.element_config_base),
        jsondecode(local.bundesmessenger_config_overrides)
        ))
}

resource "kubernetes_config_map" "bundesmessenger_config" {
  metadata {
    name = "bundesmessenger-config"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
    labels = {
      "config_hash_element" = substr(sha256(local.bundesmessenger_config), 0, 63)
    }
  }
  data = {
    "config.json" = local.bundesmessenger_config
  }
}

resource "kubernetes_deployment" "bundesmessenger_deploy" {
  metadata {
    name = "lhs-bundesmessenger"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "bundesmessenger"
        "config_hash_element" = substr(sha256(local.bundesmessenger_config), 0, 63)
      }
    }
    template {
      metadata {
        labels = {
          app = "bundesmessenger"
          "config_hash_element" = substr(sha256(local.bundesmessenger_config), 0, 63)
        }
      }
      spec {
        container {
          name = "bundesmessenger"
          image = "gitlab.opencode.de/bwi/bundesmessenger/backend/container-images/bundesmessenger-web:2.10.0-jammy-production"
          volume_mount {
            name = "config-vol"
            mount_path = "/app/config.json"
            sub_path = "config.json"
          }
          port {
            container_port = 80
            name = "element"
            protocol = "TCP"
          }
          readiness_probe {
            http_get {
              path = "/"
              port = "element"
            }
            initial_delay_seconds = 5
            period_seconds = 10
          }
          liveness_probe {
            http_get {
              path = "/"
              port = "element"
            }
            initial_delay_seconds = 10
            period_seconds = 10
          }
        }
        volume {
          name = "config-vol"
          config_map {
            name = kubernetes_config_map.bundesmessenger_config.metadata[0].name
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "bundesmessenger_svc" {
  depends_on = [
    kubernetes_deployment.bundesmessenger_deploy
  ]
  metadata {
    name = "lhs-bundesmessenger"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
  }
  spec {
    selector = {
        app = "element"
    }
    port {
      name = "element"
      port = 80
    }
  }
}


resource "kubernetes_ingress_v1" "bundesmessenger_ingress" {
  metadata {
    name = "lhs-bundesmessenger"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" = "lets-encrypt-http"
    }
  }
  spec {
    // ingress_class_name = "public"
    rule {
      host = "bm.${var.element_fqdn}"
      http {
        path {
          backend {
            service {
              name = kubernetes_service.bundesmessenger_svc.metadata[0].name
              port {
                name = "element"
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "lhs-bundesmessenger-web-cert"
      hosts = [
        var.element_fqdn
      ]
    }
  }
}