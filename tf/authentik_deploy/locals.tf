locals {
    //            ${kubernetes_secret_v1.authentik_secret.metadata[0].name}
    envFromValueStuff = <<EOF
global:
    envValueFrom:
        AUTHENTIK_BOOTSTRAP_TOKEN:
            secretKeyRef:
                key: authentik_bootstrap_token
                name: secret_name_here
        AUTHENTIK_BOOTSTRAP_PASSWORD:
            secretKeyRef:
                key: authentik_bootstrap_pass
                name: secret_name_here
        AUTHENTIK_POSTGRESQL__PASSWORD:
            secretKeyRef:
                key: postgresql-password
                name: secret_name_here
        AUTHENTIK_SECRET_KEY:
            secretKeyRef:
                key: authentik_secret_key
                name: secret_name_here
EOF
    ingress_annotations = <<EOF
server:
    ingress:
        annotations:
            cert-manager.io/cluster-issuer: ${var.authentik_ingress_annotations}
EOF
    authentik_value_combined = [yamlencode(module.deepmerge.merged)]
}

module "deepmerge" {
  source  = "Invicton-Labs/deepmerge/null"
  version = "0.1.5"
  maps = [
    yamldecode(var.authentik_values), 
        # yamldecode(local.envFromValueStuff),
        var.authentik_ingress_annotations == "" ? {} : yamldecode(local.ingress_annotations)
  ]
  # insert the 1 required variable here
}