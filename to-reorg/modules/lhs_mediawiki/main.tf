terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    authentik = {
      source = "goauthentik/authentik"
      version = "2022.6.3"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.6.0"
    }
  }
}

resource "kubernetes_namespace" "mediawiki_ns" {
  metadata {
    name = "lhs-mediawiki"
  }
}