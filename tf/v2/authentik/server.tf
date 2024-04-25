locals {
  server_labels = {
    "app" = "authentik",
    "component" = "server"
  }
}

resource "kubernetes_deployment" "authentik_server" {
    metadata {
      name = "authentik-server"
      namespace = local.namespace_name
    }
    spec {
      replicas = 1
      selector {
        match_labels = local.server_labels
      }
      template {
        metadata {
            labels = local.server_labels
        }
        spec {
          
        }
      }
    }
}