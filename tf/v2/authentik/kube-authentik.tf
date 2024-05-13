resource "kubernetes_service_account" "authentik" {
  metadata {
    labels = {
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "serviceAccount"
      "app.kubernetes.io/part-of"    = "authentik"
      "app.kubernetes.io/version"    = "2.0.0"
      "helm.sh/chart"                = "serviceAccount-2.0.0"
    }
    name      = "authentik"
    namespace = "NAMESPACE_HERE"
  }
}


resource "kubernetes_cluster_role" "authentik" {
  metadata {
    labels = {
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "serviceAccount"
      "app.kubernetes.io/part-of"    = "authentik"
      "app.kubernetes.io/version"    = "2.0.0"
      "helm.sh/chart"                = "serviceAccount-2.0.0"
    }
    name = "authentik"
  }
  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["list"]
  }
}

resource "kubernetes_cluster_role_binding" "authentik" {
  metadata {
    labels = {
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "serviceAccount"
      "app.kubernetes.io/part-of"    = "authentik"
      "app.kubernetes.io/version"    = "2.0.0"
      "helm.sh/chart"                = "serviceAccount-2.0.0"
    }
    name = "authentik"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "authentik"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "authentik"
    namespace = "NAMESPACE_HERE"
  }
}


resource "kubernetes_service" "authentik_server" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "authentik"
      "app.kubernetes.io/part-of"    = "authentik"
      "app.kubernetes.io/version"    = "2024.4.1"
      "helm.sh/chart"                = "authentik-2024.4.1"
    }
    name      = "authentik-server"
    namespace = "NAMESPACE_HERE"
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app.kubernetes.io/component" = "server"
      "app.kubernetes.io/instance"  = "lhs-authentik"
      "app.kubernetes.io/name"      = "authentik"
    }
    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = 9000
    }
    port {
      name        = "https"
      port        = 443
      protocol    = "TCP"
      target_port = 9443
    }
  }
}

resource "kubernetes_deployment" "authentik_server" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "server"
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "authentik"
      "app.kubernetes.io/part-of"    = "authentik"
      "app.kubernetes.io/version"    = "2024.4.1"
      "helm.sh/chart"                = "authentik-2024.4.1"
    }
    name      = "authentik-server"
    namespace = "NAMESPACE_HERE"
  }
  spec {
    replicas               = 1
    revision_history_limit = 3
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "server"
        "app.kubernetes.io/instance"  = "lhs-authentik"
        "app.kubernetes.io/name"      = "authentik"
      }
    }
    template {
      metadata {
        annotations = {
          "checksum/secret" = "ccde58a7495688f4b93a12133d845fc96344228329482f5a8b620de8b1a28800"
        }
        labels = {
          "app.kubernetes.io/component"  = "server"
          "app.kubernetes.io/instance"   = "lhs-authentik"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/name"       = "authentik"
          "app.kubernetes.io/part-of"    = "authentik"
          "app.kubernetes.io/version"    = "2024.4.1"
          "helm.sh/chart"                = "authentik-2024.4.1"
        }
      }
      spec {
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              pod_affinity_term {
                label_selector {
                  match_labels = {
                    "app.kubernetes.io/component" = "server"
                    "app.kubernetes.io/instance"  = "lhs-authentik"
                    "app.kubernetes.io/name"      = "authentik"
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
              weight = 100
            }
          }
        }
        container {
          name              = "server"
          image             = "ghcr.io/goauthentik/server:2024.4.1"
          image_pull_policy = "IfNotPresent"
          args              = ["server"]
          env {
            name  = "AUTHENTIK_LISTEN__HTTP"
            value = "0.0.0.0:9000"
          }
          env {
            name  = "AUTHENTIK_LISTEN__HTTPS"
            value = "0.0.0.0:9443"
          }
          env {
            name  = "AUTHENTIK_LISTEN__METRICS"
            value = "0.0.0.0:9300"
          }
          env_from {
            secret_ref {
              name = "authentik"
            }
          }
          port {
            container_port = 9000
            name           = "http"
            protocol       = "TCP"
          }
          port {
            container_port = 9443
            name           = "https"
            protocol       = "TCP"
          }
          port {
            container_port = 9300
            name           = "metrics"
            protocol       = "TCP"
          }
          resources {
            limits = {
                cpu    = "1000m"
                memory = "768Mi"
            }
            requests = {
                cpu    = "100m"
                memory = "64Mi"
            }
          }
          liveness_probe {
            failure_threshold = 3
            http_get {
              path = "/-/health/live/"
              port = "http"
            }
            initial_delay_seconds = 120
            period_seconds        = 60
            success_threshold     = 1
            timeout_seconds       = 1
          }
          readiness_probe {
            failure_threshold = 3
            http_get {
              path = "/-/health/ready/"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 1
          }
          startup_probe {
            failure_threshold = 60
            http_get {
              path = "/-/health/live/"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 1
          }
          volume_mount {
            mount_path = "/media"
            name       = "media"
          }
        }
        enable_service_links             = true
        termination_grace_period_seconds = 30
        volume {
          name = "media"
          persistent_volume_claim {
            // TODO
            claim_name = "PVC_NAME_HERE"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "authentik_worker" {
  metadata {
    labels = {
        "app.kubernetes.io/component"  = "worker"
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "authentik"
        "app.kubernetes.io/part-of"    = "authentik"
        "app.kubernetes.io/version"    = "2024.4.1"
        "helm.sh/chart"                = "authentik-2024.4.1"
    }
    name = "authentik-worker"
    namespace = "NAMESPACE_HERE"
  }
  spec {
    replicas               = 1
    revision_history_limit = 3
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "worker"
        "app.kubernetes.io/instance"  = "lhs-authentik"
        "app.kubernetes.io/name"      = "authentik"
      }
    }
    template {
      metadata {
        annotations = {
        "checksum/secret" = "ccde58a7495688f4b93a12133d845fc96344228329482f5a8b620de8b1a28800"
        }
        labels = {
        "app.kubernetes.io/component"  = "worker"
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "authentik"
        "app.kubernetes.io/part-of"    = "authentik"
        "app.kubernetes.io/version"    = "2024.4.1"
        "helm.sh/chart"                = "authentik-2024.4.1"
        }
      }
      spec {
        service_account_name = "authentik"
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              pod_affinity_term {
                label_selector {
                  match_labels = {
                    "app.kubernetes.io/component" = "server"
                    "app.kubernetes.io/instance"  = "lhs-authentik"
                    "app.kubernetes.io/name"      = "authentik"
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
              weight = 100
            }
          }
        }
        container {
            name              = "worker"
            image             = "ghcr.io/goauthentik/server:2024.4.1"
            image_pull_policy = "IfNotPresent"
            args              = ["worker"]
            env_from {
                secret_ref {
                    name = "authentik"
                }
            }
            resources {
                limits = {
                    cpu    = "1000m"
                    memory = "512Mi"
                }
                requests = {
                    cpu    = "100m"
                    memory = "64Mi"
                }
            }
            startup_probe {
              exec {
                command = [ "ak", "healthcheck" ]
              }
              failure_threshold = 60
              initial_delay_seconds = 5
              period_seconds = 10
              success_threshold = 1
              timeout_seconds = 1
            }
            liveness_probe {
              exec {
                command = [ "ak", "healthcheck" ]
              }
              failure_threshold = 3
              initial_delay_seconds = 5
              period_seconds = 10
              success_threshold = 1
              timeout_seconds = 1
            }
            readiness_probe {
              exec {
                command = [ "ak", "healthcheck" ]
              }
              failure_threshold = 3
              initial_delay_seconds = 5
              period_seconds = 10
              success_threshold = 1
              timeout_seconds = 1
            }
        }
        enable_service_links             = true
        termination_grace_period_seconds = 30
      }
    }

  }
}