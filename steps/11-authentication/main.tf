terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.11.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubectl_config
}

provider "helm" {
  kubernetes {
    config_path = var.kubectl_config
  }
}

module "lhs_authentik" {
  source = "../../tf/authentik_deploy"
  authentik_values = "${file("config/authentik.yaml")}"
  authentik_domain = "authentik.dev.gwen.org.uk"
  authentik_version = "2024.4.1"
  authentik_ingress_annotations = "lets-encrypt-http"
}