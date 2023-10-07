// TODO Rest of the fecking owl

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
  }
}

resource "kubernetes_namespace" "registry_ns" {
  metadata {
    name = "lhs-wordpress"
  }
}