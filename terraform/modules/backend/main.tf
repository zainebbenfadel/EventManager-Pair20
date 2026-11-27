resource "kubernetes_persistent_volume_claim" "sqlite-pvc" {
  metadata { name = "sqlite-pvc" }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "1Gi" }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_deployment" "backend-deployment" {
  metadata {
    name   = "backend-deployment"
    labels = { app = "backend" }
  }
  spec {
    replicas = 2
    selector {
      match_labels = { app = "backend" }
    }
    template {
      metadata { labels = { app = "backend" } }
      spec {
        security_context {
          run_as_user     = 1000
          run_as_non_root = true
          fs_group        = 1000   # lets UID 1000 write to the PVC
        }
        container {
          name  = "backend"
          image = "zaiiiineb/eventmanager-backend:latest"

          port { container_port = 8000 }

          security_context {
            run_as_user                = 1000
            run_as_non_root            = true
            allow_privilege_escalation = false
          }

          resources {
            limits   = { cpu = "500m", memory = "512Mi" }
            requests = { cpu = "100m", memory = "128Mi" }
          }

          liveness_probe {
            http_get {
              path = "/events/"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          readiness_probe {
            http_get {
              path = "/events/"
              port = 8000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          volume_mount {
            name       = "sqlite-storage"
            mount_path = "/app/data"
          }
        }
        volume {
          name = "sqlite-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.sqlite-pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend-service" {
  metadata { name = "backend-service" }
  spec {
    type     = "ClusterIP"
    selector = { app = "backend" }
    port {
      port        = 8000
      target_port = 8000
    }
  }
}