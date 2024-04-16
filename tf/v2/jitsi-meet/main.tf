terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

locals {
  namespace_name = ""
}

resource "kubernetes_service" "jvb_service" {
    metadata {
      labels = {
        "service" = "jitsi-jvb"
      }
      name = "jvb-udp"
      namespace = local.namespace_name
    }
    spec {
      type = "NodePort"
      external_traffic_policy = "Cluster"
      port {
        port = 30300
        protocol = "UDP"
        target_port = 30300
        node_port = 30300
      }
      selector = {
        "app" = "jitsi"
      }
    }
}


resource "kubernetes_service" "web_service" {
    metadata {
      labels = {
        "service" = "jitsi-web"
      }
      name = "web"
      namespace = local.namespace_name
    }
    spec {
      port {
        port = 80
        name = "http"
        target_port = 80
      }
      port {
        port = 443
        name = "https"
        target_port = 443
      }
      selector = {
        "app" = "jitsi"
      }
    }
}
