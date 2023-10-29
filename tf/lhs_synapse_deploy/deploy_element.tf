locals {
    element_config_overrides = <<EOF
{
    "default_server_config": {
        "m.homeserver": {
            "base_url": "https://${var.synapse_fqdn}"
        }
    }
}
EOF
    element_config = jsonencode(merge(
        jsondecode(var.element_config_base),
        jsondecode(local.element_config_overrides)
        ))
}

resource "kubernetes_config_map" "element_config" {
  metadata {
    name = "element-config"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
    labels = {
      "config_hash_element" = substr(sha256(local.element_config), 0, 63)
    }
  }
  data = {
    "config.json" = local.element_config
  }
}

resource "kubernetes_deployment" "element_deploy" {
  metadata {
    name = "lhs-element"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "element"
        "config_hash_element" = substr(sha256(local.element_config), 0, 63)
      }
    }
    template {
      metadata {
        labels = {
          app = "element"
          "config_hash_element" = substr(sha256(local.element_config), 0, 63)
        }
      }
      spec {
        container {
          name = "element"
          image = "vectorim/element-web:${var.element_ver}"
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
            name = kubernetes_config_map.element_config.metadata[0].name
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "element_svc" {
  depends_on = [
    kubernetes_deployment.element_deploy
  ]
  metadata {
    name = "lhs-element"
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


resource "kubernetes_ingress_v1" "element_ingress" {
  metadata {
    name = "lhs-element"
    namespace = kubernetes_namespace.matrix_ns.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "public"
    rule {
      host = var.element_fqdn
      http {
        path {
          backend {
            service {
              name = kubernetes_service.element_svc.metadata[0].name
              port {
                name = "element"
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "lhs-element-web-cert"
      hosts = [
        var.element_fqdn
      ]
    }
  }
}