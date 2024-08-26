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
    authentik = {
      source = "goauthentik/authentik"
      version = "2023.8.0"
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

data "terraform_remote_state" "authentication" {
    backend = "local"

    config = {
        path = "../11-authentication/terraform.tfstate"
    }
}

provider "authentik" {
  url   = "https://${data.terraform_remote_state.authentication.outputs.authentik_fqdn}"
  token = data.terraform_remote_state.authentication.outputs.authentik_key
}


module "lhs_synapse_deploy" {
  source = "../../tf/synapse_deploy"
  authentik_fqdn         = data.terraform_remote_state.authentication.outputs.authentik_fqdn
  synapse_config_base    = "${file("config/synapse.yaml")}"
  synapse_config_logging = "${file("config/synapse-log.yaml")}"
  element_config_base    = "${file("config/element-config.json")}"
  synapse_fqdn = "synapse.dev.gwen.org.uk"
  element_fqdn = "element.dev.gwen.org.uk"
}