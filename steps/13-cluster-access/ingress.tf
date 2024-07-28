resource "kubernetes_ingress_v1" "kube_api_ingress" {
  metadata {
    name = "kube-api-ingress"
    namespace = "default"
  }
  spec {
    rule {
      host = "kube.dev.gwen.org.uk"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "kubernetes"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = "kube-ingress-secret"
    }
  }
}