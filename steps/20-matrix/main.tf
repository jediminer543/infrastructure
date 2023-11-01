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

data "terraform_remote_state" "authentication" {
    backend = "local"

    config = {
        path = "../11-authentication"
    }
}

provider "authentik" {
  url   = "https://${data.terraform_remote_state.authentication.outputs.authentik_fqdn}"
  token = data.terraform_remote_state.authentication.outputs.authentik_key
}


module "lhs_synapse_deploy" {
  source = "../../tf/lhs_synapse_deploy"
  authentik_fqdn         = data.terraform_remote_state.authentication.outputs.authentik_fqdn
  synapse_config_base    = "${file("config/synapse.yaml")}"
  synapse_config_logging = "${file("config/synapse-log.yaml")}"
  element_config_base    = "${file("config/element-config.json")}"
  synapse_fqdn = "synapse.devel.leedshackspace.org.uk"
  element_fqdn = "element.devel.leedshackspace.org.uk"
}