terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    authentik = {
      source = "goauthentik/authentik"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubectl_config
}
