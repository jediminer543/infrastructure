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

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "hedgedoc"
  }
}