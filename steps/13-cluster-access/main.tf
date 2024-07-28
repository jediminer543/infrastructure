terraform {
  required_providers {
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

//TODO: make this use remote state at some point
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

