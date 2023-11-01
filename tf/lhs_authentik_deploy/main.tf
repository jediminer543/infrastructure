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

/*
resource "kubernetes_deployment_v1" "authentik_deployment" {
  metadata{
    namespace = kubernetes_namespace.namespace.metadata[0].name
    name = "lhs-authentik-deploy"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "authentik"
      }
    }
    template {
      metadata {
        labels = {
          app = "authentik"
        }
      }
      spec {
        image = "ghcr.io/goauthentik/server:2022.12.2"
      }
    }
  }
}
*/

resource "kubernetes_persistent_volume_claim_v1" "authentik_media" {
  metadata {
    name = "authentik-media"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteMany"]
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


resource "helm_release" "authentik" {
  name       = "lhs-authentik"
  namespace  = kubernetes_namespace.namespace.metadata[0].name
  repository = "https://charts.goauthentik.io"
  chart      = "authentik"
  version    = var.authentik_version
  create_namespace = false

  values = local.authentik_value_combined

  # 
  /*
  set {
    name = "authentik.secret_key"
    value = random_password.authentik_secret_key.result
  }
  set {
    name = "authentik.postgresql.password"
    value = random_password.authentik_db_pass.result
  }
  */
  /*
  set {
    name = "env.AUTHENTIK_BOOTSTRAP_TOKEN"
    value = random_password.authentik_bootstrap_token.result
  }
  set {
    name = "env.AUTHENTIK_BOOTSTRAP_PASSWORD"
    value = random_password.authentik_bootstrap_pass.result
  }
  */
  /*
  set {
    name = "envValueFrom"
    value = <<EOF
AUTHENTIK_BOOTSTRAP_TOKEN:
  secretKeyRef:
    key: authentik_bootstrap_token
    name: ${kubernetes_secret_v1.authentik_secret.metadata[0].name}
AUTHENTIK_BOOTSTRAP_PASSWORD:
  secretKeyRef:
    key: authentik_bootstrap_pass
    name: ${kubernetes_secret_v1.authentik_secret.metadata[0].name}
AUTHENTIK_POSTGRESQL__PASSWORD:
  secretKeyRef:
    key: postgresql-password
    name: ${kubernetes_secret_v1.authentik_secret.metadata[0].name}
AUTHENTIK_SECRET_KEY:
  secretKeyRef:
    key: authentik_secret_key
    name: ${kubernetes_secret_v1.authentik_secret.metadata[0].name}
    EOF
  }
  */
  /*
  - AUTHENTIK_BOOTSTRAP_PASSWORD:
  secretKeyRef:
    key: authentik_bootstrap_pass
    name: ${kubernetes_secret_v1.authentik_secret.metadata[0].name}
- AUTHENTIK_POSTGRESQL__PASSWORD:
  secretKeyRef:
    key: postgresql-password
    name: ${kubernetes_secret_v1.authentik_secret.metadata[0].name}
- AUTHENTIK_SECRET_KEY:
  secretKeyRef:
    key: authentik_secret_key
    name: ${kubernetes_secret_v1.authentik_secret.metadata[0].name}
  */
  /*
  yamlencode([
      "AUTHENTIK_BOOTSTRAP_TOKEN":yamlencode({"secretKeyRef":{"key": "authentik_bootstrap_token","name": kubernetes_secret_v1.authentik_secret.metadata[0].name}}),
      "AUTHENTIK_BOOTSTRAP_PASSWORD":yamlencode({"secretKeyRef":{"key": "authentik_bootstrap_pass","name": kubernetes_secret_v1.authentik_secret.metadata[0].name}}),
      "AUTHENTIK_POSTGRESQL__PASSWORD":yamlencode({"secretKeyRef":{"key": "postgresql-password","name": kubernetes_secret_v1.authentik_secret.metadata[0].name}}),
      "AUTHENTIK_SECRET_KEY":yamlencode({"secretKeyRef":{"key": "authentik_secret_key","name": kubernetes_secret_v1.authentik_secret.metadata[0].name}})
    ])
  */
  /*
  yamlencode({
      "AUTHENTIK_BOOTSTRAP_TOKEN":{"secretKeyRef":{"key": "authentik_bootstrap_token","name": kubernetes_secret_v1.authentik_secret.metadata[0].name}},
      "AUTHENTIK_BOOTSTRAP_PASSWORD":{"secretKeyRef":{"key": "authentik_bootstrap_pass","name": kubernetes_secret_v1.authentik_secret.metadata[0].name}},
      "AUTHENTIK_POSTGRESQL__PASSWORD":{"secretKeyRef":{"key": "postgresql-password","name": kubernetes_secret_v1.authentik_secret.metadata[0].name}}
      "AUTHENTIK_SECRET_KEY":{"secretKeyRef":{"key": "authentik_secret_key","name": kubernetes_secret_v1.authentik_secret.metadata[0].name}}
    })
  */
  set {
    name = "postgresql.existingSecret"
    value = kubernetes_secret_v1.authentik_secret.metadata[0].name
  }
  /*
  set {
    name = "postgresql.postgresqlPassword"
    value = random_password.authentik_db_pass.result
  }
  */
  set {
    name = "ingress.hosts[0].host"
    value = var.authentik_domain
  }
  set {
    name = "ingress.tls[0].hosts[0]"
    value = var.authentik_domain
  }
  set {
    name = "ingress.tls[0].secretName"
    value = "authentik-web-cert"
  }
  // Media storage
  set {
    name = "volumeMounts[0].mountPath"
    value = "/media"
  }
  set {
    name = "volumeMounts[0].name"
    value = "media"
  }
  set {
    name = "volumes[0].name"
    value = "media"
  }
  set {
    name = "volumeMounts[0].persistentVolumeClaim.claimName"
    value = kubernetes_persistent_volume_claim_v1.authentik_media.metadata[0].name
  }
  /*
  dynamic "set" {
    for_each = var.authentik_ingress_certman == "" ? [] : [var.authentik_ingress_certman]
    content {
      name = "ingress"
    }
  }
  */
  timeout = "900"
}