resource "kubernetes_deployment" "frontend-deployment" {
  metadata { name = "frontend-deployment" }
  spec {
    replicas = 2
    selector {
      match_labels = { app = "frontend" }
    }
    template {
      metadata { labels = { app = "frontend" } }
      spec {
        container {
          name  = "frontend"
          image = "zaiiiineb/eventmanager-frontend:latest"
          port { container_port = 80 }
          env {
            name  = "VITE_API_BASE_URL"
            value = "http://${var.laptop_a_ip}:8000"
          }
          resources {
            limits = { cpu = "500m", memory = "512Mi" }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend-service" {
  metadata { name = "frontend-service" }
  spec {
    type     = "LoadBalancer"
    selector = { app = "frontend" }
    port {
      port        = 80
      target_port = 80
    }
  }
}