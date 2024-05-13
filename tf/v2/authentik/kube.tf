resource "kubernetes_service_account" "authentik_redis" {
  metadata {
    labels = {
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "redis"
      "app.kubernetes.io/version"    = "7.2.3"
      "helm.sh/chart"                = "redis-18.6.1"
    }
    name      = "authentik-redis"
    namespace = "NAMESPACE_HERE"
  }
  automount_service_account_token = true
}

resource "kubernetes_manifest" "role_namespace_here_authentik" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "Role"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "serviceAccount"
        "app.kubernetes.io/part-of"    = "authentik"
        "app.kubernetes.io/version"    = "2.0.0"
        "helm.sh/chart"                = "serviceAccount-2.0.0"
      }
      "name"      = "authentik"
      "namespace" = "NAMESPACE_HERE"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "secrets",
          "services",
          "configmaps",
        ]
        "verbs" = [
          "get",
          "create",
          "delete",
          "list",
          "patch",
        ]
      },
      {
        "apiGroups" = [
          "extensions",
          "apps",
        ]
        "resources" = [
          "deployments",
        ]
        "verbs" = [
          "get",
          "create",
          "delete",
          "list",
          "patch",
        ]
      },
      {
        "apiGroups" = [
          "extensions",
          "networking.k8s.io",
        ]
        "resources" = [
          "ingresses",
        ]
        "verbs" = [
          "get",
          "create",
          "delete",
          "list",
          "patch",
        ]
      },
      {
        "apiGroups" = [
          "traefik.containo.us",
          "traefik.io",
        ]
        "resources" = [
          "middlewares",
        ]
        "verbs" = [
          "get",
          "create",
          "delete",
          "list",
          "patch",
        ]
      },
      {
        "apiGroups" = [
          "monitoring.coreos.com",
        ]
        "resources" = [
          "servicemonitors",
        ]
        "verbs" = [
          "get",
          "create",
          "delete",
          "list",
          "patch",
        ]
      },
      {
        "apiGroups" = [
          "apiextensions.k8s.io",
        ]
        "resources" = [
          "customresourcedefinitions",
        ]
        "verbs" = [
          "list",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "rolebinding_namespace_here_authentik" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "RoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "serviceAccount"
        "app.kubernetes.io/part-of"    = "authentik"
        "app.kubernetes.io/version"    = "2.0.0"
        "helm.sh/chart"                = "serviceAccount-2.0.0"
      }
      "name"      = "authentik"
      "namespace" = "NAMESPACE_HERE"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "Role"
      "name"     = "authentik"
    }
    "subjects" = [
      {
        "kind"      = "ServiceAccount"
        "name"      = "authentik"
        "namespace" = "NAMESPACE_HERE"
      },
    ]
  }
}





resource "kubernetes_service" "authentik_redis_headless" {
  metadata {
    labels = {
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "redis"
      "app.kubernetes.io/version"    = "7.2.3"
      "helm.sh/chart"                = "redis-18.6.1"
    }
    name      = "authentik-redis-headless"
    namespace = "NAMESPACE_HERE"
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "tcp-redis"
      port        = 6379
      target_port = "redis"
    }
    selector = {
      "app.kubernetes.io/instance" = "lhs-authentik"
      "app.kubernetes.io/name"     = "redis"
    }

  }
}

resource "kubernetes_service" "authentik_redis_master" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "master"
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "redis"
      "app.kubernetes.io/version"    = "7.2.3"
      "helm.sh/chart"                = "redis-18.6.1"
    }
    name      = "authentik-redis-master"
    namespace = "NAMESPACE_HERE"
  }
  spec {
    type             = "ClusterIP"
    session_affinity = "None"
    port {
      name        = "tcp-redis"
      port        = 6379
      target_port = "redis"
    }
    selector = {
      "app.kubernetes.io/component" = "master"
      "app.kubernetes.io/instance"  = "lhs-authentik"
      "app.kubernetes.io/name"      = "redis"
    }

  }
}



resource "kubernetes_manifest" "statefulset_namespace_here_lhs_authentik_postgresql" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "StatefulSet"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component"  = "primary"
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "postgresql"
        "app.kubernetes.io/version"    = "15.4.0"
        "helm.sh/chart"                = "postgresql-12.12.10"
      }
      "name"      = "lhs-authentik-postgresql"
      "namespace" = "NAMESPACE_HERE"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "primary"
          "app.kubernetes.io/instance"  = "lhs-authentik"
          "app.kubernetes.io/name"      = "postgresql"
        }
      }
      "serviceName" = "lhs-authentik-postgresql-hl"
      "template" = {
        "metadata" = {
          "annotations" = {
            "checksum/extended-configuration" = "f231c584ead90a4176b09eb6d6073240ab2939b8bd09b20013265962083b3208"
          }
          "labels" = {
            "app.kubernetes.io/component"  = "primary"
            "app.kubernetes.io/instance"   = "lhs-authentik"
            "app.kubernetes.io/managed-by" = "Helm"
            "app.kubernetes.io/name"       = "postgresql"
            "app.kubernetes.io/version"    = "15.4.0"
            "helm.sh/chart"                = "postgresql-12.12.10"
          }
          "name" = "lhs-authentik-postgresql"
        }
        "spec" = {
          "affinity" = {
            "nodeAffinity" = null
            "podAffinity"  = null
            "podAntiAffinity" = {
              "preferredDuringSchedulingIgnoredDuringExecution" = [
                {
                  "podAffinityTerm" = {
                    "labelSelector" = {
                      "matchLabels" = {
                        "app.kubernetes.io/component" = "primary"
                        "app.kubernetes.io/instance"  = "lhs-authentik"
                        "app.kubernetes.io/name"      = "postgresql"
                      }
                    }
                    "topologyKey" = "kubernetes.io/hostname"
                  }
                  "weight" = 1
                },
              ]
            }
          }
          "containers" = [
            {
              "env" = [
                {
                  "name"  = "BITNAMI_DEBUG"
                  "value" = "false"
                },
                {
                  "name"  = "POSTGRESQL_PORT_NUMBER"
                  "value" = "5432"
                },
                {
                  "name"  = "POSTGRESQL_VOLUME_DIR"
                  "value" = "/bitnami/postgresql"
                },
                {
                  "name"  = "PGDATA"
                  "value" = "/bitnami/postgresql/data"
                },
                {
                  "name"  = "POSTGRES_USER"
                  "value" = "authentik"
                },
                {
                  "name" = "POSTGRES_PASSWORD"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key"  = "password"
                      "name" = "lhs-authentik-postgresql"
                    }
                  }
                },
                {
                  "name" = "POSTGRES_POSTGRES_PASSWORD"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key"  = "postgres-password"
                      "name" = "lhs-authentik-postgresql"
                    }
                  }
                },
                {
                  "name"  = "POSTGRES_DATABASE"
                  "value" = "authentik"
                },
                {
                  "name"  = "POSTGRESQL_ENABLE_LDAP"
                  "value" = "no"
                },
                {
                  "name"  = "POSTGRESQL_ENABLE_TLS"
                  "value" = "no"
                },
                {
                  "name"  = "POSTGRESQL_LOG_HOSTNAME"
                  "value" = "false"
                },
                {
                  "name"  = "POSTGRESQL_LOG_CONNECTIONS"
                  "value" = "false"
                },
                {
                  "name"  = "POSTGRESQL_LOG_DISCONNECTIONS"
                  "value" = "false"
                },
                {
                  "name"  = "POSTGRESQL_PGAUDIT_LOG_CATALOG"
                  "value" = "off"
                },
                {
                  "name"  = "POSTGRESQL_CLIENT_MIN_MESSAGES"
                  "value" = "error"
                },
                {
                  "name"  = "POSTGRESQL_SHARED_PRELOAD_LIBRARIES"
                  "value" = "pgaudit"
                },
              ]
              "image"           = "docker.io/bitnami/postgresql:15.4.0-debian-11-r45"
              "imagePullPolicy" = "IfNotPresent"
              "livenessProbe" = {
                "exec" = {
                  "command" = [
                    "/bin/sh",
                    "-c",
                    "exec pg_isready -U \"authentik\" -d \"dbname=authentik\" -h 127.0.0.1 -p 5432",
                  ]
                }
                "failureThreshold"    = 6
                "initialDelaySeconds" = 30
                "periodSeconds"       = 10
                "successThreshold"    = 1
                "timeoutSeconds"      = 5
              }
              "name" = "postgresql"
              "ports" = [
                {
                  "containerPort" = 5432
                  "name"          = "tcp-postgresql"
                },
              ]
              "readinessProbe" = {
                "exec" = {
                  "command" = [
                    "/bin/sh",
                    "-c",
                    "-e",
                    <<-EOT
                    exec pg_isready -U "authentik" -d "dbname=authentik" -h 127.0.0.1 -p 5432
                    [ -f /opt/bitnami/postgresql/tmp/.initialized ] || [ -f /bitnami/postgresql/.initialized ]

                    EOT
                    ,
                  ]
                }
                "failureThreshold"    = 6
                "initialDelaySeconds" = 5
                "periodSeconds"       = 10
                "successThreshold"    = 1
                "timeoutSeconds"      = 5
              }
              "resources" = {
                "limits" = {}
                "requests" = {
                  "cpu"    = "250m"
                  "memory" = "256Mi"
                }
              }
              "securityContext" = {
                "allowPrivilegeEscalation" = false
                "capabilities" = {
                  "drop" = [
                    "ALL",
                  ]
                }
                "runAsGroup"   = 0
                "runAsNonRoot" = true
                "runAsUser"    = 1001
                "seccompProfile" = {
                  "type" = "RuntimeDefault"
                }
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/bitnami/postgresql/conf/conf.d/"
                  "name"      = "postgresql-extended-config"
                },
                {
                  "mountPath" = "/dev/shm"
                  "name"      = "dshm"
                },
                {
                  "mountPath" = "/bitnami/postgresql"
                  "name"      = "data"
                },
              ]
            },
          ]
          "hostIPC"     = false
          "hostNetwork" = false
          "securityContext" = {
            "fsGroup" = 1001
          }
          "serviceAccountName" = "default"
          "volumes" = [
            {
              "configMap" = {
                "name" = "lhs-authentik-postgresql-extended-configuration"
              }
              "name" = "postgresql-extended-config"
            },
            {
              "emptyDir" = {
                "medium" = "Memory"
              }
              "name" = "dshm"
            },
          ]
        }
      }
      "updateStrategy" = {
        "rollingUpdate" = {}
        "type"          = "RollingUpdate"
      }
      "volumeClaimTemplates" = [
        {
          "apiVersion" = "v1"
          "kind"       = "PersistentVolumeClaim"
          "metadata" = {
            "annotations" = {
              "helm.sh/resource-policy" = "keep"
            }
            "name" = "data"
          }
          "spec" = {
            "accessModes" = [
              "ReadWriteOnce",
            ]
            "resources" = {
              "requests" = {
                "storage" = "8Gi"
              }
            }
          }
        },
      ]
    }
  }
}

resource "kubernetes_secret" "authentik_postgresql" {
  metadata {
    labels = {
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "postgresql"
        "app.kubernetes.io/version"    = "15.4.0"
        "helm.sh/chart"                = "postgresql-12.12.10"
    }
    name = "authentik-postgresql"
    namespace = "NAMESPACE_HERE"
  }
  type = "Opaque"
  data = {
    "password" = ""
    "postgres-password" = ""
  }
}

resource "kubernetes_manifest" "statefulset_namespace_here_lhs_authentik_redis_master" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "StatefulSet"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component"  = "master"
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "redis"
        "app.kubernetes.io/version"    = "7.2.3"
        "helm.sh/chart"                = "redis-18.6.1"
      }
      "name"      = "lhs-authentik-redis-master"
      "namespace" = "NAMESPACE_HERE"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "master"
          "app.kubernetes.io/instance"  = "lhs-authentik"
          "app.kubernetes.io/name"      = "redis"
        }
      }
      "serviceName" = "lhs-authentik-redis-headless"
      "template" = {
        "metadata" = {
          "annotations" = {
            "checksum/configmap" = "86bcc953bb473748a3d3dc60b7c11f34e60c93519234d4c37f42e22ada559d47"
            "checksum/health"    = "aff24913d801436ea469d8d374b2ddb3ec4c43ee7ab24663d5f8ff1a1b6991a9"
            "checksum/scripts"   = "43cdf68c28f3abe25ce017a82f74dbf2437d1900fd69df51a55a3edf6193d141"
            "checksum/secret"    = "44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a"
          }
          "labels" = {
            "app.kubernetes.io/component"  = "master"
            "app.kubernetes.io/instance"   = "lhs-authentik"
            "app.kubernetes.io/managed-by" = "Helm"
            "app.kubernetes.io/name"       = "redis"
            "app.kubernetes.io/version"    = "7.2.3"
            "helm.sh/chart"                = "redis-18.6.1"
          }
        }
        "spec" = {
          "affinity" = {
            "nodeAffinity" = null
            "podAffinity"  = null
            "podAntiAffinity" = {
              "preferredDuringSchedulingIgnoredDuringExecution" = [
                {
                  "podAffinityTerm" = {
                    "labelSelector" = {
                      "matchLabels" = {
                        "app.kubernetes.io/component" = "master"
                        "app.kubernetes.io/instance"  = "lhs-authentik"
                        "app.kubernetes.io/name"      = "redis"
                      }
                    }
                    "topologyKey" = "kubernetes.io/hostname"
                  }
                  "weight" = 1
                },
              ]
            }
          }
          "automountServiceAccountToken" = true
          "containers" = [
            {
              "args" = [
                "-c",
                "/opt/bitnami/scripts/start-scripts/start-master.sh",
              ]
              "command" = [
                "/bin/bash",
              ]
              "env" = [
                {
                  "name"  = "BITNAMI_DEBUG"
                  "value" = "false"
                },
                {
                  "name"  = "REDIS_REPLICATION_MODE"
                  "value" = "master"
                },
                {
                  "name"  = "ALLOW_EMPTY_PASSWORD"
                  "value" = "yes"
                },
                {
                  "name"  = "REDIS_TLS_ENABLED"
                  "value" = "no"
                },
                {
                  "name"  = "REDIS_PORT"
                  "value" = "6379"
                },
              ]
              "image"           = "registry-1.docker.io/bitnami/redis:7.2.3-debian-11-r2"
              "imagePullPolicy" = "IfNotPresent"
              "livenessProbe" = {
                "exec" = {
                  "command" = [
                    "sh",
                    "-c",
                    "/health/ping_liveness_local.sh 5",
                  ]
                }
                "failureThreshold"    = 5
                "initialDelaySeconds" = 20
                "periodSeconds"       = 5
                "successThreshold"    = 1
                "timeoutSeconds"      = 6
              }
              "name" = "redis"
              "ports" = [
                {
                  "containerPort" = 6379
                  "name"          = "redis"
                },
              ]
              "readinessProbe" = {
                "exec" = {
                  "command" = [
                    "sh",
                    "-c",
                    "/health/ping_readiness_local.sh 1",
                  ]
                }
                "failureThreshold"    = 5
                "initialDelaySeconds" = 20
                "periodSeconds"       = 5
                "successThreshold"    = 1
                "timeoutSeconds"      = 2
              }
              "resources" = {
                "limits"   = {}
                "requests" = {}
              }
              "securityContext" = {
                "allowPrivilegeEscalation" = false
                "capabilities" = {
                  "drop" = [
                    "ALL",
                  ]
                }
                "runAsGroup"   = 0
                "runAsNonRoot" = true
                "runAsUser"    = 1001
                "seccompProfile" = {
                  "type" = "RuntimeDefault"
                }
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/opt/bitnami/scripts/start-scripts"
                  "name"      = "start-scripts"
                },
                {
                  "mountPath" = "/health"
                  "name"      = "health"
                },
                {
                  "mountPath" = "/data"
                  "name"      = "redis-data"
                },
                {
                  "mountPath" = "/opt/bitnami/redis/mounted-etc"
                  "name"      = "config"
                },
                {
                  "mountPath" = "/opt/bitnami/redis/etc/"
                  "name"      = "redis-tmp-conf"
                },
                {
                  "mountPath" = "/tmp"
                  "name"      = "tmp"
                },
              ]
            },
          ]
          "enableServiceLinks" = true
          "securityContext" = {
            "fsGroup" = 1001
          }
          "serviceAccountName"            = "lhs-authentik-redis"
          "terminationGracePeriodSeconds" = 30
          "volumes" = [
            {
              "configMap" = {
                "defaultMode" = 493
                "name"        = "lhs-authentik-redis-scripts"
              }
              "name" = "start-scripts"
            },
            {
              "configMap" = {
                "defaultMode" = 493
                "name"        = "lhs-authentik-redis-health"
              }
              "name" = "health"
            },
            {
              "configMap" = {
                "name" = "lhs-authentik-redis-configuration"
              }
              "name" = "config"
            },
            {
              "emptyDir" = {}
              "name"     = "redis-tmp-conf"
            },
            {
              "emptyDir" = {}
              "name"     = "tmp"
            },
          ]
        }
      }
      "updateStrategy" = {
        "type" = "RollingUpdate"
      }
      "volumeClaimTemplates" = [
        {
          "apiVersion" = "v1"
          "kind"       = "PersistentVolumeClaim"
          "metadata" = {
            "annotations" = {
              "helm.sh/resource-policy" = "keep"
            }
            "labels" = {
              "app.kubernetes.io/component" = "master"
              "app.kubernetes.io/instance"  = "lhs-authentik"
              "app.kubernetes.io/name"      = "redis"
            }
            "name" = "redis-data"
          }
          "spec" = {
            "accessModes" = [
              "ReadWriteOnce",
            ]
            "resources" = {
              "requests" = {
                "storage" = "8Gi"
              }
            }
          }
        },
      ]
    }
  }
}

resource "kubernetes_ingress_v1" "authentik_server" {
  metadata {
    annotations = {
      "cert-manager.io/cluster-issuer" = "lets-encrypt-http"
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
    name      = "authentik-server"
    namespace = "NAMESPACE_HERE"
  }
  spec {
    rule {
      host = "map[host:authentik.dev.gwen.org.uk paths:[map[path:/ pathType:Prefix]]]"
      http {
        path {
          backend {
            service {
              name = "authentik-server"
              port {
                number = 80
              }
            }
          }
          path      = "/"
          path_type = "Prefix"
        }
      }
    }
    tls {
      hosts       = ["authentik.dev.gwen.org.uk"]
      secret_name = "authentik-web-cert"
    }
  }
}

resource "kubernetes_manifest" "secret_namespace_here_lhs_authentik" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "AUTHENTIK_EMAIL__PORT"                       = "NTg3"
      "AUTHENTIK_EMAIL__TIMEOUT"                    = "MzA="
      "AUTHENTIK_EMAIL__USE_SSL"                    = "ZmFsc2U="
      "AUTHENTIK_EMAIL__USE_TLS"                    = "ZmFsc2U="
      "AUTHENTIK_ERROR_REPORTING__ENABLED"          = "dHJ1ZQ=="
      "AUTHENTIK_ERROR_REPORTING__ENVIRONMENT"      = "azhz"
      "AUTHENTIK_ERROR_REPORTING__SEND_PII"         = "ZmFsc2U="
      "AUTHENTIK_EVENTS__CONTEXT_PROCESSORS__ASN"   = "L2dlb2lwL0dlb0xpdGUyLUFTTi5tbWRi"
      "AUTHENTIK_EVENTS__CONTEXT_PROCESSORS__GEOIP" = "L2dlb2lwL0dlb0xpdGUyLUNpdHkubW1kYg=="
      "AUTHENTIK_LOG_LEVEL"                         = "aW5mbw=="
      "AUTHENTIK_OUTPOSTS__CONTAINER_IMAGE_BASE"    = "Z2hjci5pby9nb2F1dGhlbnRpay8lKHR5cGUpczolKHZlcnNpb24pcw=="
      "AUTHENTIK_POSTGRESQL__HOST"                  = "bGhzLWF1dGhlbnRpay1wb3N0Z3Jlc3Fs"
      "AUTHENTIK_POSTGRESQL__NAME"                  = "YXV0aGVudGlr"
      "AUTHENTIK_POSTGRESQL__PORT"                  = "NTQzMg=="
      "AUTHENTIK_POSTGRESQL__USER"                  = "YXV0aGVudGlr"
      "AUTHENTIK_REDIS__HOST"                       = "bGhzLWF1dGhlbnRpay1yZWRpcy1tYXN0ZXI="
    }
    "kind" = "Secret"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "authentik"
        "app.kubernetes.io/part-of"    = "authentik"
        "app.kubernetes.io/version"    = "2024.4.1"
        "helm.sh/chart"                = "authentik-2024.4.1"
      }
      "name"      = "lhs-authentik"
      "namespace" = "NAMESPACE_HERE"
    }
  }
}

resource "kubernetes_manifest" "configmap_namespace_here_lhs_authentik_postgresql_extended_configuration" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "override.conf" = "max_connections = 500"
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component"  = "primary"
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "postgresql"
        "app.kubernetes.io/version"    = "15.4.0"
        "helm.sh/chart"                = "postgresql-12.12.10"
      }
      "name"      = "lhs-authentik-postgresql-extended-configuration"
      "namespace" = "NAMESPACE_HERE"
    }
  }
}

resource "kubernetes_manifest" "configmap_namespace_here_lhs_authentik_redis_configuration" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "master.conf"  = <<-EOT
      dir /data
      # User-supplied master configuration:
      rename-command FLUSHDB ""
      rename-command FLUSHALL ""
      # End of master configuration
      EOT
      "redis.conf"   = <<-EOT
      # User-supplied common configuration:
      # Enable AOF https://redis.io/topics/persistence#append-only-file
      appendonly yes
      # Disable RDB persistence, AOF persistence already enabled.
      save ""
      # End of common configuration
      EOT
      "replica.conf" = <<-EOT
      dir /data
      # User-supplied replica configuration:
      rename-command FLUSHDB ""
      rename-command FLUSHALL ""
      # End of replica configuration
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "redis"
        "app.kubernetes.io/version"    = "7.2.3"
        "helm.sh/chart"                = "redis-18.6.1"
      }
      "name"      = "lhs-authentik-redis-configuration"
      "namespace" = "NAMESPACE_HERE"
    }
  }
}

resource "kubernetes_manifest" "configmap_namespace_here_lhs_authentik_redis_health" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "ping_liveness_local.sh"             = <<-EOT
      #!/bin/bash

      [[ -f $REDIS_PASSWORD_FILE ]] && export REDIS_PASSWORD="$(< "$${REDIS_PASSWORD_FILE}")"
      [[ -n "$REDIS_PASSWORD" ]] && export REDISCLI_AUTH="$REDIS_PASSWORD"
      response=$(
        timeout -s 15 $1 \
        redis-cli \
          -h localhost \
          -p $REDIS_PORT \
          ping
      )
      if [ "$?" -eq "124" ]; then
        echo "Timed out"
        exit 1
      fi
      responseFirstWord=$(echo $response | head -n1 | awk '{print $1;}')
      if [ "$response" != "PONG" ] && [ "$responseFirstWord" != "LOADING" ] && [ "$responseFirstWord" != "MASTERDOWN" ]; then
        echo "$response"
        exit 1
      fi
      EOT
      "ping_liveness_local_and_master.sh"  = <<-EOT
      script_dir="$(dirname "$0")"
      exit_status=0
      "$script_dir/ping_liveness_local.sh" $1 || exit_status=$?
      "$script_dir/ping_liveness_master.sh" $1 || exit_status=$?
      exit $exit_status
      EOT
      "ping_liveness_master.sh"            = <<-EOT
      #!/bin/bash

      [[ -f $REDIS_MASTER_PASSWORD_FILE ]] && export REDIS_MASTER_PASSWORD="$(< "$${REDIS_MASTER_PASSWORD_FILE}")"
      [[ -n "$REDIS_MASTER_PASSWORD" ]] && export REDISCLI_AUTH="$REDIS_MASTER_PASSWORD"
      response=$(
        timeout -s 15 $1 \
        redis-cli \
          -h $REDIS_MASTER_HOST \
          -p $REDIS_MASTER_PORT_NUMBER \
          ping
      )
      if [ "$?" -eq "124" ]; then
        echo "Timed out"
        exit 1
      fi
      responseFirstWord=$(echo $response | head -n1 | awk '{print $1;}')
      if [ "$response" != "PONG" ] && [ "$responseFirstWord" != "LOADING" ]; then
        echo "$response"
        exit 1
      fi
      EOT
      "ping_readiness_local.sh"            = <<-EOT
      #!/bin/bash

      [[ -f $REDIS_PASSWORD_FILE ]] && export REDIS_PASSWORD="$(< "$${REDIS_PASSWORD_FILE}")"
      [[ -n "$REDIS_PASSWORD" ]] && export REDISCLI_AUTH="$REDIS_PASSWORD"
      response=$(
        timeout -s 15 $1 \
        redis-cli \
          -h localhost \
          -p $REDIS_PORT \
          ping
      )
      if [ "$?" -eq "124" ]; then
        echo "Timed out"
        exit 1
      fi
      if [ "$response" != "PONG" ]; then
        echo "$response"
        exit 1
      fi
      EOT
      "ping_readiness_local_and_master.sh" = <<-EOT
      script_dir="$(dirname "$0")"
      exit_status=0
      "$script_dir/ping_readiness_local.sh" $1 || exit_status=$?
      "$script_dir/ping_readiness_master.sh" $1 || exit_status=$?
      exit $exit_status
      EOT
      "ping_readiness_master.sh"           = <<-EOT
      #!/bin/bash

      [[ -f $REDIS_MASTER_PASSWORD_FILE ]] && export REDIS_MASTER_PASSWORD="$(< "$${REDIS_MASTER_PASSWORD_FILE}")"
      [[ -n "$REDIS_MASTER_PASSWORD" ]] && export REDISCLI_AUTH="$REDIS_MASTER_PASSWORD"
      response=$(
        timeout -s 15 $1 \
        redis-cli \
          -h $REDIS_MASTER_HOST \
          -p $REDIS_MASTER_PORT_NUMBER \
          ping
      )
      if [ "$?" -eq "124" ]; then
        echo "Timed out"
        exit 1
      fi
      if [ "$response" != "PONG" ]; then
        echo "$response"
        exit 1
      fi
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "redis"
        "app.kubernetes.io/version"    = "7.2.3"
        "helm.sh/chart"                = "redis-18.6.1"
      }
      "name"      = "lhs-authentik-redis-health"
      "namespace" = "NAMESPACE_HERE"
    }
  }
}

resource "kubernetes_manifest" "configmap_namespace_here_lhs_authentik_redis_scripts" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "start-master.sh" = <<-EOT
      #!/bin/bash

      [[ -f $REDIS_PASSWORD_FILE ]] && export REDIS_PASSWORD="$(< "$${REDIS_PASSWORD_FILE}")"
      if [[ -f /opt/bitnami/redis/mounted-etc/master.conf ]];then
          cp /opt/bitnami/redis/mounted-etc/master.conf /opt/bitnami/redis/etc/master.conf
      fi
      if [[ -f /opt/bitnami/redis/mounted-etc/redis.conf ]];then
          cp /opt/bitnami/redis/mounted-etc/redis.conf /opt/bitnami/redis/etc/redis.conf
      fi
      ARGS=("--port" "$${REDIS_PORT}")
      ARGS+=("--protected-mode" "no")
      ARGS+=("--include" "/opt/bitnami/redis/etc/redis.conf")
      ARGS+=("--include" "/opt/bitnami/redis/etc/master.conf")
      exec redis-server "$${ARGS[@]}"
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "redis"
        "app.kubernetes.io/version"    = "7.2.3"
        "helm.sh/chart"                = "redis-18.6.1"
      }
      "name"      = "lhs-authentik-redis-scripts"
      "namespace" = "NAMESPACE_HERE"
    }
  }
}

