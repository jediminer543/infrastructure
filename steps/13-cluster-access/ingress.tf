resource "kubernetes_ingress" "kube_api_ingress" {
  metadata {
    name = "kube_api_ingress"
    namespace = "kube-bolton"
  }
  spec {
    backend {
      service_name = "kubernetes.default"
      service_port = "443"
    }
    rule {
      host = "kube.dev.gwen.org.uk"
      http {
        path {
          path = "/"
          backend {
            service_name = "kubernetes.default"
            service_port = "443"
          }
        }
      }
    }
  }
}