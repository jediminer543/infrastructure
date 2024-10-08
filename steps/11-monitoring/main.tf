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

module "lhs_monitoring" {
  source = "../../tf/lhs_monitoring_deploy"
  kps_ingress = true
  kps_root_domain = "monitoring.gwen.org.uk"
  kps_version = "52.1.0"
}