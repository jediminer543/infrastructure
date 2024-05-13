resource "kubernetes_service" "authentik_postgresql_hl" {
  metadata {
    annotations = {
      "service.alpha.kubernetes.io/tolerate-unready-endpoints" = "true"
    }
    labels = {
      "app.kubernetes.io/component"  = "primary"
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "postgresql"
      "app.kubernetes.io/version"    = "15.4.0"
      "helm.sh/chart"                = "postgresql-12.12.10"
    }
    name      = "postgresql-hl"
    namespace = "NAMESPACE_HERE"
  }
  spec {
    type                        = "ClusterIP"
    publish_not_ready_addresses = true
    selector = {
      "app.kubernetes.io/component" = "primary"
      "app.kubernetes.io/instance"  = "lhs-authentik"
      "app.kubernetes.io/name"      = "postgresql"
    }
    port {
      name        = "tcp-postgresql"
      port        = 5432
      target_port = "tcp-postgresql"
    }
  }
}

resource "kubernetes_service" "authentik_postgresql" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "primary"
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "postgresql"
      "app.kubernetes.io/version"    = "15.4.0"
      "helm.sh/chart"                = "postgresql-12.12.10"
    }
    name      = "postgresql"
    namespace = "NAMESPACE_HERE"
  }
  spec {
    type             = "ClusterIP"
    session_affinity = "None"
    port {
      name        = "tcp-postgresql"
      port        = 5432
      target_port = "tcp-postgresql"
    }
    selector = {
      "app.kubernetes.io/component" = "primary"
      "app.kubernetes.io/instance"  = "lhs-authentik"
      "app.kubernetes.io/name"      = "postgresql"
    }

  }
}