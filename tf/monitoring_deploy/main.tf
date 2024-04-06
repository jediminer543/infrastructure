terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "monitoring"
  }
}

// https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
resource "helm_release" "monitoring" { 
    name       = "prometheus"
    namespace  = kubernetes_namespace.namespace.metadata[0].name
    repository = "https://prometheus-community.github.io/helm-charts"
    chart      = "kube-prometheus-stack"
    version    = "${var.kps_version}"
    create_namespace = false

    // Externally initialised operator
    set {
        name = "prometheusOperator.enabled"
        value = false
    }
    set {
        name = "crds.enabled"
        value = false
    }

    // The below settings ensure cross namespace access
    set {
        name = "prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues"
        value = false
    }
    set {
        name = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
        value = false
    }
    set {
        name = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
        value = false
    }
    // Ingress
    // Alert Manager
    set {
      name = "alertmanager.ingress.enabled"
      value = var.kps_ingress
    }
    set {
      name = "alertmanager.ingress.hosts[0]"
      value = "alertmanager.${var.kps_root_domain}"
    }
    // Grafana
    set {
      name = "grafana.ingress.enabled"
      value = var.kps_ingress
    }
    set {
      name = "grafana.ingress.hosts[0]"
      value = "grafana.${var.kps_root_domain}"
    }
    // prometheus
    set {
      name = "prometheus.ingress.enabled"
      value = var.kps_ingress
    }
    set {
      name = "prometheus.ingress.hosts[0]"
      value = "prometheus.${var.kps_root_domain}"
    }
}