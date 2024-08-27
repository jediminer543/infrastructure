terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "bundesmessenger"
  }
}