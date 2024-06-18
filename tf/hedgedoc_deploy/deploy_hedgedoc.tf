resource "kubernetes_secret" "hedgedoc" {
  metadata {
    labels = {
      "app.kubernetes.io/name"       = "hedgedoc"
      "app.kubernetes.io/component"  = "hedgedoc"
      "app.kubernetes.io/part-of"    = "gwen-hedgedoc"
      "app.kubernetes.io/managed-by" = "gwen"
    }
    name      = "hedgedoc"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  data = {
    "CMD_DB_URL" = local.database_url
    "CMD_OAUTH2_PROVIDERNAME" = "authentik"
    "CMD_OAUTH2_CLIENT_ID" = authentik_provider_oauth2.hedgedoc_oidc.client_id
    "CMD_OAUTH2_CLIENT_SECRET" = authentik_provider_oauth2.hedgedoc_oidc.client_secret
    "CMD_OAUTH2_SCOPE" = "openid email profile"
    "CMD_OAUTH2_USER_PROFILE_URL" = "https://${var.authentik_fqdn}/application/o/userinfo/"
    "CMD_OAUTH2_TOKEN_URL" = "https://${var.authentik_fqdn}/application/o/token/"
    "CMD_OAUTH2_AUTHORIZATION_URL" = "https://${var.authentik_fqdn}/application/o/authorize/"
    "CMD_OAUTH2_USER_PROFILE_USERNAME_ATTR" = "preferred_username"
    "CMD_OAUTH2_USER_PROFILE_DISPLAY_NAME_ATTR" = "name"
    "CMD_OAUTH2_USER_PROFILE_EMAIL_ATTR" = "email"
  }
}

resource "kubernetes_persistent_volume_claim" "hedgedoc" {
  metadata {
    labels = {
      "app.kubernetes.io/name" = "hedgedoc-uploads"
      "app.kubernetes.io/component" = "storage"
      "app.kubernetes.io/part-of" = "gwen-hedgedoc-test"
    }
    name = "uploads"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    access_modes = [ "ReadWriteMany" ]
    resources {
      requests = {
        "storage" = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "hedgedoc" {
  metadata {
    labels = {
      "app.kubernetes.io/name"       = "hedgedoc"
      "app.kubernetes.io/component"  = "hedgedoc"
      "app.kubernetes.io/part-of"    = "gwen-hedgedoc"
      "app.kubernetes.io/managed-by" = "gwen"
    }
    name      = "hedgedoc"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app"                         = "hedgedoc"
        "app.kubernetes.io/name"      = "hedgedoc"
        "app.kubernetes.io/component" = "hedgedoc"
        "app.kubernetes.io/part-of"   = "gwen-hedgedoc-test"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          "app"                         = "hedgedoc"
          "app.kubernetes.io/name"      = "hedgedoc"
          "app.kubernetes.io/component" = "hedgedoc"
          "app.kubernetes.io/part-of"   = "gwen-hedgedoc-test"
        }
      }
      spec {
        container {
          name  = "hedgedoc"
          image = "quay.io/hedgedoc/hedgedoc:1.9.9"
          port {
            container_port = 3000
            protocol       = "TCP"
          }
          env {
            name  = "CMD_DOMAIN"
            value = var.hedgedoc_fqdn
          }
          env {
            name  = "CMD_URL_ADDPORT"
            value = "false"
          }
          env {
            name  = "CMD_PROTOCOL_USESSL"
            value = "true"
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.hedgedoc.metadata[0].name
            }
          }
          volume_mount {
            name = "uploads"
            mount_path = "/hedgedoc/public/uploads"
          }
        }
        restart_policy = "Always"
        volume {
          name = "uploads"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.hedgedoc.metadata[0].name
          }
        }
      }
    }
  }
}
