terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    authentik = {
      source = "goauthentik/authentik"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

resource "kubernetes_namespace" "matrix_ns" {
  metadata {
    name = "lhs-matrix"
  }
}