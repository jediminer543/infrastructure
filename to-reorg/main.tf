terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "2022.6.3"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.6.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
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

provider "authentik" {
  url   = "https://${module.lhs_authentik.authentik_fqdn}"
  token = module.lhs_authentik.authentik_key
  insecure = true
}

module "lhs_monitoring" {
  source = "./modules/lhs_monitoring_deploy"
  kps_ingress = true
  kps_root_domain = "monitoring.devel.leedshackspace.org.uk"
}

/*
module "lhs_registry" {
  source = "./modules/lhs_registry_deploy"
}
*/

module "lhs_authentik" {
  source = "./modules/lhs_authentik_deploy"
  authentik_values = "${file("config/authentik.yaml")}"
  authentik_domain = "authentik.devel.leedshackspace.org.uk"
  authentik_version = "2023.1.2"
  authentik_ingress_annotations = "letsencrypt-prod"
  depends_on = [
    module.lhs_monitoring
  ]
}

/*
module "lhs_authentik_provision" {
  source = "./modules/lhs_authentic_provision"
  depends_on = [
    module.lhs_authentik
  ]
}
*/

module "lhs_synapse_deploy" {
  source = "./modules/lhs_synapse_deploy"
  authentik_fqdn         = module.lhs_authentik.authentik_fqdn
  synapse_config_base    = "${file("config/synapse.yaml")}"
  synapse_config_logging = "${file("config/synapse-log.yaml")}"
  element_config_base    = "${file("config/element-config.json")}"
  synapse_fqdn = "synapse.devel.leedshackspace.org.uk"
  element_fqdn = "element.devel.leedshackspace.org.uk"
  synapse_cert_stuff = { enable = false, secret="cacert" }
  depends_on = [
    module.lhs_authentik
  ]
}

module "lhs_mediawiki" {
  source = "./modules/lhs_mediawiki"
  authentik_fqdn         = module.lhs_authentik.authentik_fqdn
  depends_on = [
    module.lhs_authentik
  ]
}