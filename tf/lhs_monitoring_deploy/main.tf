terraform {
  required_providers {
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

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "lhs-monitoring"
  }
}

// https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
resource "helm_release" "monitoring" { 
    name       = "lhs-prometheus"
    namespace  = kubernetes_namespace.namespace.metadata[0].name
    repository = "https://prometheus-community.github.io/helm-charts"
    chart      = "kube-prometheus-stack"
    version    = "${var.kps_version}"
    create_namespace = false

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
    set {
      name = "prometheus.resources.limits.cpu"
      value = "100m"
    }
    set {
      name = "prometheus.resources.limits.memory"
      value = "100M"
    }

}