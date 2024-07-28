locals {
    //            ${kubernetes_secret_v1.authentik_secret.metadata[0].name}
    envFromValueStuff = <<EOF
global:
    envFrom:
        - secretRef:
            name: ${kubernetes_secret_v1.authentik_secret.metadata[0].name}
EOF
    ingress_annotations = <<EOF
server:
    ingress:
        annotations:
            cert-manager.io/cluster-issuer: ${var.authentik_ingress_annotations}
            traefik.ingress.kubernetes.io/router.entrypoints: websecure
EOF
    authentik_value_combined = [yamlencode(module.deepmerge.merged)]
}

module "deepmerge" {
  source  = "Invicton-Labs/deepmerge/null"
  version = "0.1.5"
  maps = [
    yamldecode(var.authentik_values), 
        yamldecode(local.envFromValueStuff),
        var.authentik_ingress_annotations == "" ? {} : yamldecode(local.ingress_annotations)
  ]
  # insert the 1 required variable here
}