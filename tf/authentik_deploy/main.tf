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
    name = "lhs-authentik"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "authentik_media" {
  metadata {
    name = "authentik-media"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "500Mi"
      }
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "kubernetes_secret_v1" "authentik_secret" {
  metadata{
    namespace = kubernetes_namespace.namespace.metadata[0].name
    name = "authentik-secrets"
  }
  data = {
    "authentik_secret_key" =  random_password.authentik_secret_key.result,
    "authentik_db_pass" = random_password.authentik_db_pass.result,
    "authentik_bootstrap_token" = random_password.authentik_bootstrap_token.result,
    "authentik_bootstrap_pass" = random_password.authentik_bootstrap_pass.result,
    "postgresql-password" = random_password.authentik_db_pass.result,
    "postgresql-postgres-password" = random_password.authentik_postgress_pass.result,
  }
}


resource "helm_release" "authentik" {
  name       = "authentik"
  namespace  = kubernetes_namespace.namespace.metadata[0].name
  repository = "https://charts.goauthentik.io"
  chart      = "authentik"
  version    = var.authentik_version
  create_namespace = false

  values = local.authentik_value_combined

  set_sensitive {
    name = "postgresql.auth.postgresPassword"
    value = random_password.authentik_postgress_pass.result
  }

  set {
    name = "server.ingress.hosts[0].host"
    value = var.authentik_domain
  }
  set {
    name = "server.ingress.tls[0].hosts[0]"
    value = var.authentik_domain
  }
  set {
    name = "server.ingress.tls[0].secretName"
    value = "authentik-web-cert"
  }
  // Media storage
  set {
    name = "server.volumeMounts[0].mountPath"
    value = "/media"
  }
  set {
    name = "server.volumeMounts[0].name"
    value = "media"
  }
  set {
    name = "server.volumes[0].name"
    value = "media"
  }
  set {
    name = "server.volumeMounts[0].persistentVolumeClaim.claimName"
    value = kubernetes_persistent_volume_claim_v1.authentik_media.metadata[0].name
  }

  # dynamic "set" {
  #   for_each = var.authentik_ingress_certman == "" ? [] : [var.authentik_ingress_certman]
  #   content {
  #     name = "ingress"
  #   }
  # }
  
  timeout = "900"
}