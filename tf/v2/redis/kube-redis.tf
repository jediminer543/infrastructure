resource "kubernetes_config_map" "redis_configuration" {
  metadata {
    labels = {
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "redis"
      "app.kubernetes.io/version"    = "7.2.3"
      "helm.sh/chart"                = "redis-18.6.1"
    }
    name = "authentik-redis-configuration"
    namespace = "NAMESPACE_HERE"
  }
  data = {
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
}

resource "kubernetes_config_map" "redis_health" {
  metadata {
    labels = {
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "redis"
      "app.kubernetes.io/version"    = "7.2.3"
      "helm.sh/chart"                = "redis-18.6.1"
    }
    name      = "authentik-redis-health"
    namespace = "NAMESPACE_HERE"
  }
  data = {
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
}

resource "kubernetes_config_map" "redis_scripts" {
  metadata {
    labels = {
        "app.kubernetes.io/instance"   = "lhs-authentik"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name"       = "redis"
        "app.kubernetes.io/version"    = "7.2.3"
        "helm.sh/chart"                = "redis-18.6.1"
    }
    name      = "authentik-redis-scripts"
    namespace = "NAMESPACE_HERE"
  }
  data = {
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
}

resource "kubernetes_service" "redis_headless" {
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

resource "kubernetes_service" "redis_master" {
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

resource "kubernetes_service_account" "redis" {
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

resource "kubernetes_stateful_set" "redis_master" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "master"
      "app.kubernetes.io/instance"   = "lhs-authentik"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "redis"
      "app.kubernetes.io/version"    = "7.2.3"
      "helm.sh/chart"                = "redis-18.6.1"
    }
    name = "redis-master"
    namespace = "NAMESPACE_HERE"
  }
  spec {
    replicas = 1
    selector {
      match_labels =  {
        "app.kubernetes.io/component" = "master"
        "app.kubernetes.io/instance"  = "lhs-authentik"
        "app.kubernetes.io/name"      = "redis"      
      }
    }
    service_name = "redis-headless"
    template {
      metadata {
        labels = {
          "app.kubernetes.io/component"  = "master"
          "app.kubernetes.io/instance"   = "lhs-authentik"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/name"       = "redis"
          "app.kubernetes.io/version"    = "7.2.3"
          "helm.sh/chart"                = "redis-18.6.1"
        }
      }
      spec {
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              pod_affinity_term {
                label_selector {
                  match_labels = {
                    "app.kubernetes.io/component" = "master"
                    "app.kubernetes.io/instance"  = "lhs-authentik"
                    "app.kubernetes.io/name"      = "redis"
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
              weight = 1
            }
          }
        }
        automount_service_account_token = true
        enable_service_links = true
        security_context {
          fs_group = 1001
        }
        service_account_name = "redis"
        termination_grace_period_seconds = 30
        volume {
          config_map {
            default_mode = 493
            name        = "redis-scripts"
          }
          name = "start-scripts"
        }
        volume {
          config_map {
            default_mode = 493
            name        = "redis-health"
          }
          name = "health"
        }
        volume {
          config_map {
            name = "redis-configuration"
          }
          name = "config"
        }
        volume {
          empty_dir {}
          name     = "redis-tmp-conf"
        }
        volume {
          empty_dir {}
          name     = "tmp"
        }
        container {
          name = "redis"
          image           = "registry-1.docker.io/bitnami/redis:7.2.3-debian-11-r2"
          image_pull_policy = "IfNotPresent"
          args = [
            "-c",
            "/opt/bitnami/scripts/start-scripts/start-master.sh",
          ]
          command = [
            "/bin/bash",
          ]
          port {
            container_port = 6379
            name          = "redis"
          }
          env {
            name  = "BITNAMI_DEBUG"
            value = "false"
          }
          env {
            name  = "REDIS_REPLICATION_MODE"
            value = "master"
          }
          env {
            name  = "ALLOW_EMPTY_PASSWORD"
            value = "yes"
          }
          env {
            name  = "REDIS_TLS_ENABLED"
            value = "no"
          }
          env {
            name  = "REDIS_PORT"
            value = "6379"
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = [
                "ALL",
              ]
            }
            run_as_group   = 0
            run_as_non_root = true
            run_as_user    = 1001
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
          liveness_probe {
            exec {
              command = [
                "sh",
                "-c",
                "/health/ping_liveness_local.sh 5",
              ]
            }
            failure_threshold      = 5
            initial_delay_seconds  = 20
            period_seconds         = 5
            success_threshold      = 1
            timeout_seconds        = 6
          }
          readiness_probe  {
            exec {
              command = [
                "sh",
                "-c",
                "/health/ping_readiness_local.sh 1",
              ]
            }
            failure_threshold      = 5
            initial_delay_seconds  = 20
            period_seconds         = 5
            success_threshold      = 1
            timeout_seconds        = 2
          }
          volume_mount {
            mount_path = "/opt/bitnami/scripts/start-scripts"
            name      = "start-scripts"
          }
          volume_mount {
            mount_path = "/health"
            name      = "health"
          }
          volume_mount {
            mount_path = "/data"
            name      = "redis-data"
          }
          volume_mount {
            mount_path = "/opt/bitnami/redis/mounted-etc"
            name      = "config"
          }
          volume_mount {
            mount_path = "/opt/bitnami/redis/etc/"
            name      = "redis-tmp-conf"
          }
          volume_mount {
            mount_path = "/tmp"
            name      = "tmp"
          }
          resources {
            limits   = {}
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
    update_strategy {
      type = "RollingUpdate"
    }
    volume_claim_template {
      metadata {
        annotations = {
          "helm.sh/resource-policy" = "keep"
        }
        labels = {
          "app.kubernetes.io/component" = "master"
          "app.kubernetes.io/instance"  = "lhs-authentik"
          "app.kubernetes.io/name"      = "redis"
        }
        name = "redis-data"
      }
      spec {
        access_modes = [
          "ReadWriteOnce",
        ]
        resources {
          requests = {
            "storage" = "8Gi"
          }
        }
      }
    }
  }
}